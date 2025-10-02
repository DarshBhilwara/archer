#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "Error at line $LINENO: command failed." >&2; exit 1' ERR

echo -n "Please Enter Disk to partition (ex /dev/sda or /dev/nvme0n1): "
read -r DISK
if [[ ! -b "$DISK" ]]; then
  echo "Invalid disk: $DISK" >&2
  exit 1
fi

echo "This will erase all data on $DISK!"
read -rp "Type YES to continue: " CONFIRM
[[ "$CONFIRM" != "YES" ]] && { echo "Aborted by user."; exit 1; }

read -rp "Enter EFI partition size (e.g., 512M): " EFI_SIZE
read -rp "Enter Boot partition size (e.g., 1G): " BOOT_SIZE
read -rp "Enter Root(/) partition size (e.g., 30G): " ROOT_SIZE

echo "Wiping and partitioning $DISK..."
wipefs -a "$DISK"
sgdisk --zap-all "$DISK"

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
mkfs.fat -F32 "$EFI"
mkfs.ext4 -F "$BOOT"
mkfs.ext4 -F "$ROOT"
mkfs.ext4 -F "$HOME"

echo "--------------------"
echo "----- Mounting -----"
echo "--------------------"
mount "$ROOT" /mnt
mkdir -p /mnt/{boot,home}
mount "$BOOT" /mnt/boot
mount "$HOME" /mnt/home


echo "--------------------------------------"
echo "----- Installing Base Arch Linux -----"
echo "--------------------------------------"
pacstrap /mnt base git vim sudo --noconfirm --needed

echo "----------------------------"
echo "----- Generating fstab -----"
echo "----------------------------"
genfstab -U /mnt > /mnt/etc/fstab

echo "---------------------------"
echo "----- Generating swap -----"
echo "---------------------------"
arch-chroot /mnt bash -c "
fallocate -l 10G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
"

arch-chroot /mnt systemctl daemon-reexec || true

cp user.sh post.sh /mnt/root/
chmod +x /mnt/root/{user.sh,post.sh}
echo "$EFI" > /mnt/root/.efi_partition

echo "---------------------------"
echo "----- Going to chroot -----"
echo "---------------------------"
arch-chroot /mnt /root/user.sh
