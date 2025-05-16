#!/usr/bin/env bash
set -e 

echo -n "Please Enter Disk to partition (ex /dev/sda or /dev/nvme0n1): "
read DISK

echo "This will erase all data on $DISK!"
read -rp "Type YES to continue: " CONFIRM
[[ "$CONFIRM" != "YES" ]] && { echo "Aborted."; exit 1; }

echo -n "Enter EFI partition size (e.g., 512M): "
read EFI_SIZE
echo -n "Enter Boot partition size (e.g., 1G): "
read BOOT_SIZE
echo -n "Enter Root(/) partition size (e.g., 30G): "
read ROOT_SIZE

echo "Wiping and partitioning $DISK..."

# Wipe disk
wipefs -a "$DISK"
sgdisk --zap-all "$DISK"

# Create partitions
fdisk "$DISK" <<EOF
g

n
1

+${EFI_SIZE}
t
1

n
2

+${BOOT_SIZE}

n
3

+${ROOT_SIZE}

n
4


w
EOF

sleep 1

fdisk "$DISK" <<EOF
t
1
1
w
EOF

sleep 1

# Set partition variables depending on disk type
if [[ "$DISK" == *"nvme"* ]]; then
  EFI="${DISK}p1"
  BOOT="${DISK}p2"
  ROOT="${DISK}p3"
  HOME="${DISK}p4"
else
  EFI="${DISK}1"
  BOOT="${DISK}2"
  ROOT="${DISK}3"
  HOME="${DISK}4"
fi

echo "-------------------------------"
echo "----- Creating filesystem -----"
echo "-------------------------------"

mkfs.fat -F32 "${EFI}"
mkfs.ext4 "${BOOT}"
mkfs.ext4 "${ROOT}"
mkfs.ext4 "${HOME}"

echo "--------------------"
echo "----- Mounting -----"
echo "--------------------"

mount "${ROOT}" /mnt
mkdir -p /mnt/boot
mount "${BOOT}" /mnt/boot
mkdir /mnt/home
mount "${HOME}" /mnt/home

echo "--------------------------------------"
echo "----- INSTALLING Base Arch Linux -----"
echo "--------------------------------------"
pacstrap /mnt base git vim sudo --noconfirm --needed 

echo "----------------------------"
echo "----- Generating fstab -----"
echo "----------------------------"
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt systemctl daemon-reexec

mkdir -p /mnt/root
cp user.sh /mnt/root/user.sh
cp post.sh /mnt/root/post.sh
chmod +x /mnt/root/user.sh 
chmod +x /mnt/root/post.sh

echo "---------------------------"
echo "----- Going to chroot -----"
echo "---------------------------"
echo "$EFI" > /mnt/root/.efi_partition
arch-chroot /mnt /root/user.sh


