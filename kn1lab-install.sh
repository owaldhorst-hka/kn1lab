#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$(uname -o)" == "Msys" || "$(uname -o)" == "Cygwin" || "$(uname -o)" == "MS/Windows" ]]; then
    SCRIPT_DIR=$(cygpath -w "$SCRIPT_DIR")
fi

# Variables
VM_NAME="kn1lab"
MEMORY_SIZE=4096
CPU_COUNT=2
CLOUD_IMG_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
VDI_SIZE=20000 # Size in MB, equivalent to 20 GB
SSH_HOST_PORT=22
SSH_GUEST_PORT=22
CLOUD_INIT_ISO="cloud-init.iso"
UBUNTU_IMG="ubuntu-22.04-cloud.img"

# Set paths relative to the script's location
CLOUD_IMG_PATH="$SCRIPT_DIR/$UBUNTU_IMG"
VDI_PATH="$SCRIPT_DIR/vm_disk.vdi"
CLOUD_CONFIG_TMP_DIR="$SCRIPT_DIR/tmp"
CLOUD_CONFIG_PATH="$CLOUD_CONFIG_TMP_DIR/user-data"
CLOUD_INIT_ISO_PATH="$SCRIPT_DIR/$CLOUD_INIT_ISO"

# Determine OS and set variables
if [[ "$(uname)" == "Linux" ]]; then
    OS_TYPE="Linux"
elif [[ "$(uname -o)" == "Msys" || "$(uname -o)" == "Cygwin" || "$(uname -o)" == "MS/Windows" ]]; then
    OS_TYPE="Windows"
else
    echo "Unsupported OS type: $(uname)"
    exit 1
fi

# Check if the Ubuntu Cloud Image already exists, if not download it
if [[ ! -f "$CLOUD_IMG_PATH" ]]; then
    echo "Ubuntu Cloud Image not found, downloading..."
    if [[ "$OS_TYPE" == "Linux" ]]; then
        wget -O "$CLOUD_IMG_PATH" "$CLOUD_IMG_URL"
    else
        powershell.exe -Command "Invoke-WebRequest -Uri '$CLOUD_IMG_URL' -OutFile '$CLOUD_IMG_PATH'"
    fi
else
    echo "Using existing Ubuntu Cloud Image at $CLOUD_IMG_PATH"
fi

PASSWORD="kn1lab"
PASSWORD_HASH=$(openssl passwd -6 "$PASSWORD")

# Check if the cloud-init ISO already exists, if not create it
if [[ ! -f "$CLOUD_INIT_ISO_PATH" ]]; then
    echo "Cloud-init ISO not found, creating..."

    # Create tmp directory if it doesn't exist
    if [[ "$OS_TYPE" == "Linux" ]]; then
        mkdir -p "$CLOUD_CONFIG_TMP_DIR"
    else
        powershell.exe -Command "New-Item -Path '$CLOUD_CONFIG_TMP_DIR' -ItemType Directory -Force"
    fi
    
    # Create cloud-config file after tmp folder is created
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
      - <Öffentlicher SSH-Schlüssel>
runcmd:
 - [ git, clone, https://github.com/owaldhorst-hka/CPUnetPLOT ]
 - [ cd, /home/labrat ]
 - [ git, clone, https://github.com/owaldhorst-hka/kn1lab ]
 - [ mkdir, -m, 777, /home/labrat/Maildir ]
 - [ mkdir, -m, 777, /home/labrat/Maildir/new ]
 - [ mkdir, -m, 777, /home/labrat/Maildir/cur ]
 - [ mkdir, -m, 777, /home/labrat/Maildir/tmp ]
EOF

    # Create cloud-init ISO
    if [[ "$OS_TYPE" == "Linux" ]]; then
        touch "$CLOUD_CONFIG_TMP_DIR/meta-data"
        genisoimage -output "$CLOUD_INIT_ISO_PATH" -volid cidata -joliet -rock "$CLOUD_CONFIG_TMP_DIR"
    else
        powershell.exe -Command "New-Item -Path '$CLOUD_CONFIG_TMP_DIR\\meta-data' -ItemType File"
        powershell.exe -Command "& 'C:\Program Files (x86)\cdrtools\mkisofs.exe' -output '$CLOUD_INIT_ISO_PATH' -volid cidata -joliet -rock '$CLOUD_CONFIG_TMP_DIR'"
    fi
else
    echo "Using existing cloud-init ISO at $CLOUD_INIT_ISO_PATH"
fi

# Install qemu-img if not installed (Linux only)
if ! command -v qemu-img &> /dev/null
then
    echo "qemu-img could not be found, installing..."
    if [[ "$OS_TYPE" == "Linux" ]]; then
        sudo apt install qemu-utils -y
    else
        echo "Please install qemu-img manually on Windows."
        exit 1
    fi
fi

# Convert the downloaded cloud image to a VDI file for VirtualBox
qemu-img convert -O vdi "$CLOUD_IMG_PATH" "$VDI_PATH"

# Resize the VDI file to the specified size (in MB)
VBoxManage modifymedium disk "$VDI_PATH" --resize $VDI_SIZE

# Create VM
VBoxManage createvm --name "$VM_NAME" --ostype "Ubuntu_64" --register

# Modify VM
VBoxManage modifyvm "$VM_NAME" --memory $MEMORY_SIZE --cpus $CPU_COUNT

# Create and attach virtual hard disk
VBoxManage storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VDI_PATH"

# Attach the cloud-init ISO
VBoxManage storagectl "$VM_NAME" --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach "$VM_NAME" --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium "$CLOUD_INIT_ISO_PATH"

# Configure network (NAT with port forwarding)
VBoxManage modifyvm "$VM_NAME" --nic1 nat
VBoxManage modifyvm "$VM_NAME" --natpf1 "ssh,tcp,127.0.0.1,$SSH_HOST_PORT,,$SSH_GUEST_PORT"

# Start VM in headless mode
VBoxManage startvm "$VM_NAME" --type headless

# Reset known ssh hosts, because these tend to throw an error
ssh-keygen -R localhost

# Clean up tmp folder if it was created by the script
if [[ ! -f "$CLOUD_CONFIG_TMP_DIR" ]]; then
    if [[ "$OS_TYPE" == "Linux" ]]; then
        rm -rf "$CLOUD_CONFIG_TMP_DIR"
    else
        powershell.exe -Command "Remove-Item -Recurse -Force '$CLOUD_CONFIG_TMP_DIR'"
    fi
fi

echo "VM created and started in headless mode."
echo "You can SSH into the VM using: ssh labrat@localhost"

