#!/bin/bash

####################################################################################################
# Variables & Constants
VM_NAME="kn1lab"
MEMORY_SIZE=4096
CPU_COUNT=2
DISC_SIZE=20480 
SSH_HOST_PORT=2222
SSH_GUEST_PORT=22
PID_FILE="pidfile.txt"
UBUNTU_VERSION="ubuntu-22.04-cloud"
CLOUD_INIT_ISO="cloud-init.iso"
SHA256SUMS_URL="https://cloud-images.ubuntu.com/jammy/current/SHA256SUMS"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCH="$(uname -m)"

####################################################################################################
# PID Validation Logic (Cross-Platform)

check_running_vm() {
    if [ -f "$PID_FILE" ]; then
        OLD_PID=$(cat "$PID_FILE" | tr -d '\r')
        echo "Checking if existing PID $OLD_PID is still active..."
        if kill -0 "$OLD_PID" 2>/dev/null; then
            if ps -p "$OLD_PID" -o args= 2>/dev/null | grep -qE "VBoxHeadless|qemu-system|VirtualBoxVM"; then
                echo "-------------------------------------------------------------------"
                echo "ALREADY RUNNING: VM process $OLD_PID is still active."
                echo "If you want to restart, stop the VM manually first."
                echo "-------------------------------------------------------------------"
                exit 0
            fi
        fi
        echo "Stale pidfile found (Process $OLD_PID not found). Cleaning up..."
        rm -f "$PID_FILE"
    fi
}

save_vbox_pid() {
    echo "Searching for PID of VM: $VM_NAME..."
    sleep 2
    if [[ "$OS_TYPE" == "Windows" ]]; then
        PID=$(powershell.exe -Command "Get-WmiObject Win32_Process -Filter \"Name = 'VBoxHeadless.exe'\" | Where-Object { \$_.CommandLine -like '*$VM_NAME*' } | Select-Object -ExpandProperty ProcessId" | tr -d '\r' | head -n 1)
    else
        PID=$(pgrep -f "VBoxHeadless --comment $VM_NAME")
    fi

    if [[ -n "$PID" ]]; then
        echo "$PID" > "$PID_FILE"
        echo "PID $PID saved to $PID_FILE"
    else
        echo "Warning: Could not capture PID. You may need to stop the VM manually."
    fi
}

####################################################################################################
# Helper Functions

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
        if ! brew list | grep -q "^$pkg\$"; then
            missing+=("$pkg")
        fi
    done
    if [[ ${#missing[@]} -ne 0 ]]; then
        echo "Missing Homebrew packages: ${missing[*]}"
        exit 1
    fi
}

handle_linux_kvm() {
    if lsmod | grep -E "^kvm_amd\s|^kvm_intel\s" >/dev/null; then
        echo "KVM module detected. Attempting to remove it to prevent VirtualBox conflicts..."
        sudo modprobe -r kvm_intel kvm_amd 2>/dev/null
        if lsmod | grep -qE "^kvm_amd\s|^kvm_intel\s"; then
            echo "ERROR: Could not remove KVM. Please manually run 'sudo modprobe -r kvm_intel'."
            exit 1
        fi
    fi
}

check_and_start_vbox() {
    local vbm="$1"
    if "$vbm" list vms | grep -q "\"$VM_NAME\""; then
        echo "VM '$VM_NAME' already exists."
        if "$vbm" showvminfo "$VM_NAME" --machinereadable | grep -q 'VMState="running"'; then
            echo "VM is already running."
            # Ensure PID file exists even if VM was started elsewhere
            save_vbox_pid
            exit 0
        else
            echo "Starting existing VM..."
            "$vbm" startvm "$VM_NAME" --type headless
            save_vbox_pid
            exit 0
        fi
    fi
}

####################################################################################################
# SSH Key Processing

SSH_KEY_FOLDER="$HOME/.ssh/id_rsa.pub"
if [ -f "$SSH_KEY_FOLDER" ]; then
    echo "Public SSH key found."
else
    echo "No SSH key found. Generating a new one..."
    ssh-keygen -t rsa -b 4096 -N "" -f "$HOME/.ssh/id_rsa"
fi
SSH_PUB_KEY=$(cat "$SSH_KEY_FOLDER")

####################################################################################################
# Detect OS and Initial Checks

check_running_vm

if [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin" ]]; then
    OS_TYPE="Windows"
    VBOX_MANAGE="/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
    [[ ! -f "$VBOX_MANAGE" ]] && { echo "Missing: VirtualBox"; exit 1; }
    check_and_start_vbox "$VBOX_MANAGE"
    powershell.exe -Command "Start-BitsTransfer -Source '$SHA256SUMS_URL' -Destination SHA256SUMS"

elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="Mac"
    command -v brew &>/dev/null || { echo "Missing: Homebrew"; exit 1; }
    if [[ "$ARCH" == "x86_64" ]]; then
        check_homebrew_packages virtualbox wget cdrtools
        VBOX_MANAGE="/usr/local/bin/VBoxManage"
        check_and_start_vbox "$VBOX_MANAGE"
        wget -q -O SHA256SUMS "$SHA256SUMS_URL"
    else
        check_homebrew_packages qemu wget cdrtools
    fi

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="Linux"
    handle_linux_kvm
    check_programs VBoxManage mkisofs wget
    VBOX_MANAGE=$(command -v VBoxManage)
    check_and_start_vbox "$VBOX_MANAGE"
    wget -q -O SHA256SUMS "$SHA256SUMS_URL"
else
    echo "Unsupported OS: $(uname)"
    exit 1
fi

####################################################################################################
# Set appropriate Ubuntu image

if [[ "$ARCH" == "x86_64" ]]; then
    CLOUD_IMG_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.ova"
    VM_TYPE="VirtualBox"
    FILE_ENDING=".ova"
    EXPECTED_HASH=$(grep "jammy-server-cloudimg-amd64.ova" SHA256SUMS | awk '{print $1}')
elif [[ "$ARCH" == "arm64" ]]; then
    CLOUD_IMG_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-arm64.img"
    VM_TYPE="QEMU"
    FILE_ENDING=".img"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

CLOUD_IMG_PATH="$SCRIPT_DIR/$UBUNTU_VERSION$FILE_ENDING"
CLOUD_CONFIG_TMP_DIR="$SCRIPT_DIR/tmp"
MKISOFS_TMP_DIR="$SCRIPT_DIR/mkisofs"
CLOUD_CONFIG_PATH="$CLOUD_CONFIG_TMP_DIR/user-data"
CLOUD_INIT_ISO_PATH="$SCRIPT_DIR/$CLOUD_INIT_ISO"
QEMU_EFI_PATH="$SCRIPT_DIR/QEMU_EFI.fd"
QEMU_EFI_URL="https://releases.linaro.org/components/kernel/uefi-linaro/latest/release/qemu64/QEMU_EFI.fd"

####################################################################################################
# Download and Verify Image

download_cloud_iso() {
    echo "Ubuntu Cloud image not found, downloading..."
    IMG_DOWNLOADED=1
    if [[ "$OS_TYPE" == "Windows" ]]; then
        WIN_PATH=$(cygpath -w "$CLOUD_IMG_PATH")
        powershell.exe -Command "Start-BitsTransfer -Source '$CLOUD_IMG_URL' -Destination '$WIN_PATH'"
    else
        wget -O "$CLOUD_IMG_PATH" "$CLOUD_IMG_URL"
    fi
}

if [[ ! -f "$CLOUD_IMG_PATH" ]]; then
    download_cloud_iso
fi

if [[ "$ARCH" != "arm64" ]]; then
    ACTUAL_HASH=$(sha256sum "$CLOUD_IMG_PATH" | awk '{print $1}')
    if [[ "$ACTUAL_HASH" != "$EXPECTED_HASH" ]]; then
        echo "Checksum mismatch! Retrying..."
        rm -f "$CLOUD_IMG_PATH"
        download_cloud_iso
    fi
    rm -f SHA256SUMS
fi

####################################################################################################
# Create cloud-init ISO

PASSWORD_HASH=$(openssl passwd -6 "kn1lab")

if [[ ! -f "$CLOUD_INIT_ISO_PATH" ]]; then
    echo "Creating cloud-init ISO..."
    mkdir -p "$CLOUD_CONFIG_TMP_DIR"
    cat << EOF > "$CLOUD_CONFIG_PATH"
#cloud-config
users:
  - name: labrat
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    passwd: $PASSWORD_HASH
    ssh_authorized_keys:
      - $SSH_PUB_KEY
runcmd:
 - sudo -u labrat git clone https://github.com/owaldhorst-hka/CPUnetPLOT /CPUnetPLOT
 - sudo -u labrat git clone https://github.com/owaldhorst-hka/kn1lab /home/labrat/kn1lab
 - mkdir -p -m 777 /home/labrat/Maildir/new /home/labrat/Maildir/cur /home/labrat/Maildir/tmp
 - chown -R labrat:labrat /home/labrat/Maildir
EOF
    touch "$CLOUD_CONFIG_TMP_DIR/meta-data"
    
    if [[ "$OS_TYPE" != "Windows" ]]; then
        mkisofs -output "$CLOUD_INIT_ISO_PATH" -volid cidata -joliet -rock "$CLOUD_CONFIG_TMP_DIR"
    else
        GIT_LFS_SKIP_SMUDGE=1 git clone https://github.com/owaldhorst-hka/mkisofs "$MKISOFS_TMP_DIR"
        powershell.exe -Command "& '$(cygpath -w "$MKISOFS_TMP_DIR/mkisofs.exe")' -output '$(cygpath -w "$CLOUD_INIT_ISO_PATH")' -volid cidata -joliet -rock '$(cygpath -w "$CLOUD_CONFIG_TMP_DIR")'"
        rm -rf "$MKISOFS_TMP_DIR"
    fi
fi

####################################################################################################
# Start/Create VM

if [[ "$VM_TYPE" == "VirtualBox" ]]; then
    echo "Importing and starting VirtualBox VM..."
    "$VBOX_MANAGE" import "$CLOUD_IMG_PATH" --vsys 0 --vmname "$VM_NAME"
    "$VBOX_MANAGE" modifyvm "$VM_NAME" --memory $MEMORY_SIZE --cpus $CPU_COUNT --nic1 nat
    "$VBOX_MANAGE" storageattach "$VM_NAME" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "$CLOUD_INIT_ISO_PATH"
    "$VBOX_MANAGE" modifyvm "$VM_NAME" --natpf1 "ssh,tcp,127.0.0.1,$SSH_HOST_PORT,,$SSH_GUEST_PORT"
    "$VBOX_MANAGE" startvm "$VM_NAME" --type headless
    save_vbox_pid

elif [[ "$VM_TYPE" == "QEMU" ]]; then
    [[ ! -f "$QEMU_EFI_PATH" ]] && wget -O "$QEMU_EFI_PATH" "$QEMU_EFI_URL"
    if [ -n "$IMG_DOWNLOADED" ]; then
        qemu-img resize "$CLOUD_IMG_PATH" "$DISC_SIZE"M
    fi
    qemu-system-aarch64 -m "$MEMORY_SIZE"M -accel hvf -cpu host -smp $CPU_COUNT -M virt \
        --display none -daemonize -pidfile "$PID_FILE" -bios "$QEMU_EFI_PATH" \
        -device virtio-net-pci,netdev=net0 -netdev user,id=net0,hostfwd=tcp::"$SSH_HOST_PORT"-:"$SSH_GUEST_PORT" \
        -hda "$CLOUD_IMG_PATH" -cdrom "$CLOUD_INIT_ISO_PATH"
    echo "QEMU started. PID saved to $PID_FILE."
fi

####################################################################################################
# Post-VM setup tasks

ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:2222" 2>/dev/null
rm -rf "$CLOUD_CONFIG_TMP_DIR"

# VS Code settings injection
if [[ "$OS_TYPE" == "Linux" ]]; then SETTINGS_PATH="$HOME/.config/Code/User/settings.json"
elif [[ "$OS_TYPE" == "Mac" ]]; then SETTINGS_PATH="$HOME/Library/Application Support/Code/User/settings.json"
elif [[ "$OS_TYPE" == "Windows" ]]; then SETTINGS_PATH="$APPDATA/Code/User/settings.json"
fi

if [[ -n "$SETTINGS_PATH" ]]; then
    mkdir -p "$(dirname "$SETTINGS_PATH")"
    [ -f "$SETTINGS_PATH" ] || echo "{}" > "$SETTINGS_PATH"
    cp "$SETTINGS_PATH" "$SETTINGS_PATH.bak"

    desired_extensions=("vscjava.vscode-java-pack" "ms-python.python" "ms-toolsai.jupyter")
    for ext in "${desired_extensions[@]}"; do
        if ! grep -q "$ext" "$SETTINGS_PATH"; then
            if grep -q "remote.SSH.defaultExtensions" "$SETTINGS_PATH"; then
                sed -i -E "s/(\"remote.SSH.defaultExtensions\":\s*\[)/\1\"$ext\", /" "$SETTINGS_PATH"
            else
                sed -i -E 's/\{/{\n  "remote.SSH.defaultExtensions": ["'"$ext"'"],/' "$SETTINGS_PATH"
            fi
        fi
    done
fi

echo "VM created and started. PID saved to $PID_FILE."
echo "You can SSH using: ssh -p $SSH_HOST_PORT labrat@localhost"