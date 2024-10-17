#!/bin/bash

SSH_PUB_KEY=""
if [ -z "$SSH_PUB_KEY" ]; then
        echo "Please set variable \$SSH_PUB_KEY to your ssh public key."
        exit -1
fi

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect the operating system
if [[ "$(uname -o)" == "Msys" || "$(uname -o)" == "Cygwin" || "$(uname -o)" == "MS/Windows" ]]; then
    OS_TYPE="Windows"
    SCRIPT_DIR=$(cygpath -w "$SCRIPT_DIR")
elif [[ "$(uname)" == "Darwin" ]]; then
    OS_TYPE="Mac"
elif [[ "$(uname)" == "Linux" ]]; then
    OS_TYPE="Linux"
else
    echo "Unsupported OS type: $(uname)"
    exit 1
fi

# Variables
VM_NAME="kn1lab"
MEMORY_SIZE=4096
CPU_COUNT=2
SSH_HOST_PORT=2222
SSH_GUEST_PORT=22
CLOUD_INIT_ISO="cloud-init.iso"
UBUNTU_OVA="ubuntu-22.04-cloud.ova"

# Check architecture
ARCH="$(uname -m)"

# Set the appropriate Ubuntu OVA image based on architecture
if [[ "$ARCH" == "x86_64" ]]; then
    # Intel (amd64 architecture)
    CLOUD_OVA_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.ova"
    VM_TYPE="VirtualBox"
elif [[ "$ARCH" == "arm64" ]]; then
    echo "ARM-based systems not supported with VirtualBox."
    exit 1
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Set paths relative to the script's location
CLOUD_OVA_PATH="$SCRIPT_DIR/$UBUNTU_OVA"
CLOUD_CONFIG_TMP_DIR="$SCRIPT_DIR/tmp"
CLOUD_CONFIG_PATH="$CLOUD_CONFIG_TMP_DIR/user-data"
CLOUD_INIT_ISO_PATH="$SCRIPT_DIR/$CLOUD_INIT_ISO"

# Download the cloud OVA image if not found
if [[ ! -f "$CLOUD_OVA_PATH" ]]; then
    echo "Ubuntu Cloud OVA not found, downloading..."
    if [[ "$OS_TYPE" == "Linux" || "$OS_TYPE" == "Mac" ]]; then
        wget -O "$CLOUD_OVA_PATH" "$CLOUD_OVA_URL"
    else
        powershell.exe -Command "Invoke-WebRequest -Uri '$CLOUD_OVA_URL' -OutFile '$CLOUD_OVA_PATH'"
    fi
else
    echo "Using existing Ubuntu Cloud OVA at $CLOUD_OVA_PATH"
fi

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
        genisoimage -output "$CLOUD_INIT_ISO_PATH" -volid cidata -joliet -rock "$CLOUD_CONFIG_TMP_DIR"
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
    VBoxManage import "$CLOUD_OVA_PATH" --vsys 0 --vmname "$VM_NAME"

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
# Main logic to determine the VM setup based on architecture and OS
if [[ "$VM_TYPE" == "VirtualBox" ]]; then
    create_virtualbox_vm
fi

# Reset known ssh hosts, because these tend to throw an error
ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:2222"

# Clean up tmp folder if it was created by the script
if [[ ! -f "$CLOUD_CONFIG_TMP_DIR" ]]; then
     rm -rf "$CLOUD_CONFIG_TMP_DIR"
fi

echo "VM created and started."
echo "You can SSH into the VM using: ssh -p $SSH_HOST_PORT labrat@localhost"








