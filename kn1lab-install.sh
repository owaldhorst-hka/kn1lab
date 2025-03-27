#!/bin/bash

SSH_KEY_FOLDER="$HOME/.ssh/id_rsa.pub"
# Check if the public key exists
if [ -f "$SSH_KEY_FOLDER" ]; then
    echo "Public SSH key found:"
else
    echo "No SSH key found. Generating a new one..."
    ssh-keygen -t rsa -b 4096 -N "" -f "$HOME/.ssh/id_rsa"
    
    if [ -f "$SSH_KEY_FOLDER" ]; then
        echo "New SSH key generated:"
    else
        echo "Failed to generate SSH key."
        exit 1
    fi
fi
SSH_PUB_KEY=$(cat "$SSH_KEY_FOLDER")
check_programs() {
    missing=()
    for prog in "$@"; do
        if ! command -v "$prog" &>/dev/null; then
            missing+=("$prog")
        fi
    done
    if [[ ${#missing[@]} -ne 0 ]]; then
        echo "Missing programs: ${missing[*]}"
        exit 1
    fi
}
check_homebrew_packages() {
    missing=()
    for pkg in "$@"; do
        if ! brew list --formula | grep -q "^$pkg\$"; then
            missing+=("$pkg")
        fi
    done
    if [[ ${#missing[@]} -ne 0 ]]; then
        echo "Missing Homebrew packages: ${missing[*]}"
        exit 1
    fi
}

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHA256SUMS_URL="https://cloud-images.ubuntu.com/jammy/current/SHA256SUMS"

# Detect the operating system
if [[ "$(uname -o)" == "Msys" || "$(uname -o)" == "Cygwin" || "$(uname -o)" == "MS/Windows" ]]; then
    OS_TYPE="Windows"
    SCRIPT_DIR=$(cygpath -w "$SCRIPT_DIR")
    if [[ -z $(echo "$PATH" | grep -i "virtualbox") ]]; then
        echo "VirtualBox is not in PATH"
        exit 1
    fi
    check_programs VBoxManage
    if [[ ! -f "/c/Program Files (x86)/cdrtools/mkisofs.exe" ]]; then
        echo "Missing: mkisofs (expected at C:\Program Files (x86)\cdrtools\mkisofs.exe)"
        exit 1
    fi
    powershell.exe -Command "Start-BitsTransfer -Source '$SHA256SUMS_URL' -Destination SHA256SUMS"

elif [[ "$(uname)" == "Darwin" ]]; then
    OS_TYPE="Mac"
    command -v brew &>/dev/null || { echo "Missing: Homebrew"; exit 1; }
    wget -q -O SHA256SUMS "$SHA256SUMS_URL"
elif [[ "$(uname)" == "Linux" ]]; then
    OS_TYPE="Linux"
    check_programs VBoxManage mkisofs
    wget -q -O SHA256SUMS "$SHA256SUMS_URL"
else
    echo "Unsupported OS type: $(uname)"
    exit 1
fi

# Variables
VM_NAME="kn1lab"
MEMORY_SIZE=4096
CPU_COUNT=2
DISC_SIZE=20480 # Size in MB, equivalent to 20 GB
SSH_HOST_PORT=2222
SSH_GUEST_PORT=22
CLOUD_INIT_ISO="cloud-init.iso"
UBUNTU_VERSION="ubuntu-22.04-cloud"


# Check architecture
ARCH="$(uname -m)"

# Set the appropriate Ubuntu image based on architecture
if [[ "$ARCH" == "x86_64" ]]; then
    if [ "$OS_TYPE" == "Mac" ]; then
        check_homebrew_packages virtualbox wget cdrtools
    fi
    # Intel (amd64 architecture)
    CLOUD_IMG_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.ova"
    VM_TYPE="VirtualBox"
    FILE_ENDING=".ova"
    EXPECTED_HASH=$(grep "jammy-server-cloudimg-amd64.ova" SHA256SUMS | awk '{print $1}')
elif [[ "$ARCH" == "arm64" ]]; then
    # ARM-based (ARM64 architecture)
    check_homebrew_packages qemu wget cdrtools
    if [ -f pidfile.txt ]; then
        echo "VM is already running, exiting..."
        exit 0
    fi
    CLOUD_IMG_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-arm64.img"
    VM_TYPE="QEMU"
    FILE_ENDING=".img"
    EXPECTED_HASH=$(grep "jammy-server-cloudimg-arm64.img" SHA256SUMS | awk '{print $1}')
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

download_cloud_iso() {
    echo "Ubuntu Cloud OVA not found, downloading..."
    IMG_DOWNLOADED=1
    if [[ "$OS_TYPE" == "Linux" || "$OS_TYPE" == "Mac" ]]; then
        wget -O "$CLOUD_IMG_PATH" "$CLOUD_IMG_URL"
    else
        powershell.exe -Command "Start-BitsTransfer -Source '$CLOUD_IMG_URL' -Destination '$CLOUD_IMG_PATH'"
    fi
}

# Set paths relative to the script's location
CLOUD_IMG_PATH="$SCRIPT_DIR/$UBUNTU_VERSION$FILE_ENDING"
CLOUD_CONFIG_TMP_DIR="$SCRIPT_DIR/tmp"
CLOUD_CONFIG_PATH="$CLOUD_CONFIG_TMP_DIR/user-data"
CLOUD_INIT_ISO_PATH="$SCRIPT_DIR/$CLOUD_INIT_ISO"

QEMU_EFI_PATH="$SCRIPT_DIR/QEMU_EFI.fd"
QEMU_EFI_URL="https://releases.linaro.org/components/kernel/uefi-linaro/latest/release/qemu64/QEMU_EFI.fd"

# Download the cloud image if not found
if [[ ! -f "$CLOUD_IMG_PATH" ]]; then
    download_cloud_iso
else
    echo "Using existing Ubuntu Cloud IMG at $CLOUD_IMG_PATH"
fi

ACTUAL_HASH=$(sha256sum "$CLOUD_IMG_PATH" | awk '{print $1}' | tr -d '[:space:]' | tr -d '\\')


if [ "$ACTUAL_HASH" != "$EXPECTED_HASH" ]; then
    echo "Checksum mismatch! Retrying download..."
    rm -f "$CLOUD_IMG_PATH"
    download_cloud_iso
    ACTUAL_HASH=$(sha256sum "$CLOUD_IMG_PATH" | awk '{print $1}' | tr -d '[:space:]' | tr -d '\\')
    if [ "$ACTUAL_HASH" != "$EXPECTED_HASH" ]; then
        echo "Cloud Image was twice not correctly downloaded, maybe retry with better connection?"
        rm -f "$CLOUD_IMG_PATH"
        rm -f SHA256SUMS
        exit 1
    fi
fi

rm -f SHA256SUMS

PASSWORD="kn1lab"
PASSWORD_HASH=$(openssl passwd -6 "$PASSWORD")

# Create cloud-init ISO if it doesn't exist
if [[ ! -f "$CLOUD_INIT_ISO_PATH" ]]; then
    echo "Cloud-init ISO not found, creating..."

    mkdir -p "$CLOUD_CONFIG_TMP_DIR"

    # Create cloud-config file
    cat << EOF > "$CLOUD_CONFIG_PATH"
#cloud-config
manage_etc_hosts: false
users:
  - name: labrat
    sudo:  ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    groups:
      - sudo
    lock_passwd: false
    passwd: $PASSWORD_HASH
    ssh_authorized_keys:
      - $SSH_PUB_KEY
runcmd:
 - [ git, clone, https://github.com/owaldhorst-hka/CPUnetPLOT ]
 - [ cd, /home/labrat ]
 - [ git, clone, https://github.com/owaldhorst-hka/kn1lab ]
 - [ mkdir, -m, 777, /home/labrat/Maildir ]
 - [ mkdir, -m, 777, /home/labrat/Maildir/new ]
 - [ mkdir, -m, 777, /home/labrat/Maildir/cur ]
 - [ mkdir, -m, 777, /home/labrat/Maildir/tmp ]
EOF

    touch "$CLOUD_CONFIG_TMP_DIR/meta-data"
    
    # Generate cloud-init ISO
    if [[ "$OS_TYPE" == "Linux" || "$OS_TYPE" == "Mac" ]]; then
        mkisofs -output "$CLOUD_INIT_ISO_PATH" -volid cidata -joliet -rock "$CLOUD_CONFIG_TMP_DIR"
    else
        powershell.exe -Command "& 'C:\Program Files (x86)\cdrtools\mkisofs.exe' -output '$CLOUD_INIT_ISO_PATH' -volid cidata -joliet -rock '$CLOUD_CONFIG_TMP_DIR'"
    fi
else
    echo "Using existing cloud-init ISO at $CLOUD_INIT_ISO_PATH"
fi

# Function to create a VM using VirtualBox with OVA
create_virtualbox_vm() {
    echo "Setting up VM using VirtualBox and OVA..."

    # Import OVA into VirtualBox
    VBoxManage import "$CLOUD_IMG_PATH" --vsys 0 --vmname "$VM_NAME"

    # Modify VM settings
    VBoxManage modifyvm "$VM_NAME" --memory $MEMORY_SIZE --cpus $CPU_COUNT

    # Attach the cloud-init ISO to the existing IDE controller (already included in the OVA)
    VBoxManage storageattach "$VM_NAME" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "$CLOUD_INIT_ISO_PATH"

    # Configure network (NAT with port forwarding)
    VBoxManage modifyvm "$VM_NAME" --nic1 nat
    VBoxManage modifyvm "$VM_NAME" --natpf1 "ssh,tcp,127.0.0.1,$SSH_HOST_PORT,,$SSH_GUEST_PORT"

    # Start VM in headless mode
    VBoxManage startvm "$VM_NAME" --type headless
}

# Function to create a VM using QEMU (for ARM-based systems)
create_qemu_vm() {
    echo "Setting up VM using QEMU (ARM-based system)..."

    # Download the EFI image
    if [[ ! -f "$QEMU_EFI_PATH" ]]; then
        echo "QEMU EFI Image not found, downloading..."
        wget -O "$QEMU_EFI_PATH" "$QEMU_EFI_URL"
    else
        echo "Using existing QEMU EFI Image at $QEMU_EFI_PATH"
    fi

    # Create cloud init iso image
    if [[ ! -f "$CLOUD_INIT_ISO_PATH" ]]; then
        echo "Cloud Init Image not found, createing..."
        mkisofs -output "$CLOUD_INIT_ISO_PATH" -volid cidata -joliet -rock {"$CLOUD_CONFIG_PATH","$CLOUD_CONFIG_TMP_DIR/meta-data"}
    else
        echo "Using existing Cloud Init Image at $CLOUD_INIT_ISO_PATH"
    fi

    # Resize the IMG file to the specified size (in MB)
    if [ -n "$IMG_DOWNLOADED" ]; then
        echo "Rezising disk..."
        qemu-img resize $UBUNTU_VERSION$FILE_ENDING "$DISC_SIZE"M
    fi

    # Run the VM using QEMU with ARM architecture
    qemu-system-aarch64 \
        -m "$MEMORY_SIZE"M \
        -accel hvf \
        -cpu host \
        -smp $CPU_COUNT \
        -M virt \
        --display none -daemonize -pidfile pidfile.txt \
        -bios QEMU_EFI.fd \
 	    -device virtio-net-pci,netdev=net0 \
        -netdev user,id=net0,hostfwd=tcp::"$SSH_HOST_PORT"-:"$SSH_GUEST_PORT" \
        -hda $CLOUD_IMG_PATH \
        -cdrom $CLOUD_INIT_ISO_PATH
}

# Main logic to determine the VM setup based on architecture and OS
if [[ "$VM_TYPE" == "VirtualBox" ]]; then
    create_virtualbox_vm
elif [[ "$VM_TYPE" == "QEMU" ]]; then
    create_qemu_vm
fi

# Reset known ssh hosts, because these tend to throw an error
if [ "$VM_TYPE" != "QEMU" ] || [ -n "$IMG_DOWNLOADED" ]; then
    touch "$HOME/.ssh/known_hosts"
    ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:2222"
fi

# Clean up tmp folder if it was created by the script
if [[ ! -f "$CLOUD_CONFIG_TMP_DIR" ]]; then
     rm -rf "$CLOUD_CONFIG_TMP_DIR"
fi

echo "VM created and started."
echo "You can SSH into the VM using: ssh -p $SSH_HOST_PORT labrat@localhost"