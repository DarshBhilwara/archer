#!/usr/bin/env bash

cat <<'EOF'

                                                                                                      
         .8.          8 888888888o.      ,o888888o.    8 8888        8 8 8888888888   8 888888888o.   
        .888.         8 8888    `88.    8888     `88.  8 8888        8 8 8888         8 8888    `88.  
       :88888.        8 8888     `88 ,8 8888       `8. 8 8888        8 8 8888         8 8888     `88  
      . `88888.       8 8888     ,88 88 8888           8 8888        8 8 8888         8 8888     ,88  
     .8. `88888.      8 8888.   ,88' 88 8888           8 8888        8 8 888888888888 8 8888.   ,88'  
    .8`8. `88888.     8 888888888P'  88 8888           8 8888        8 8 8888         8 888888888P'   
   .8' `8. `88888.    8 8888`8b      88 8888           8 8888888888888 8 8888         8 8888`8b       
  .8'   `8. `88888.   8 8888 `8b.    `8 8888       .8' 8 8888        8 8 8888         8 8888 `8b.     
 .888888888. `88888.  8 8888   `8b.     8888     ,88'  8 8888        8 8 8888         8 8888   `8b.   
.8'       `8. `88888. 8 8888     `88.    `8888888P'    8 8888        8 8 888888888888 8 8888     `88. 

EOF

set -Eeuo pipefail
trap 'echo "Error at line $LINENO"; exit 1' ERR

echo -n "Please Enter Disk to partition (ex /dev/sda or /dev/nvme0n1): "
read -r DISK
if [[ ! -b "$DISK" ]]; then
  echo "Invalid disk: $DISK" >&2
  exit 1
fi

echo "This will erase all data on $DISK!"
read -rp "Type YES to continue: " CONFIRM
[[ "$CONFIRM" == "YES" ]] || exit 1

read -rp "Enter EFI partition size (e.g., 512M): " EFI_SIZE
read -rp "Enter Boot partition size (e.g., 1G): " BOOT_SIZE
read -rp "Enter Root(/) partition size (e.g., 30G) or leave empty if you have multiple disks: " ROOT_SIZE

[[ -z "$ROOT_SIZE" ]] && { echo "Root size cannot be empty"; exit 1; }

EXTRA_DISKS=()
read -rp "Do you want to setup additional disks? [y/N]: " ADD_DISKS
ADD_DISKS=${ADD_DISKS,,}

if [[ "$ADD_DISKS" == "y" || "$ADD_DISKS" == "yes" ]]; then
  while true; do
    read -rp "Enter extra disk (e.g. /dev/sdb, /dev/nvme1n1) or press Enter to finish: " DISK_INPUT
    [[ -z "$DISK_INPUT" ]] && break

    if [[ ! -b "$DISK_INPUT" ]]; then
      echo "Invalid disk: $DISK_INPUT"
      continue
    fi

    echo " This will ERASE ALL DATA on $DISK_INPUT"
    read -rp "Type YES to confirm erasing $DISK_INPUT: " CONFIRM_ERASE

    if [[ "$CONFIRM_ERASE" != "YES" ]]; then
      echo "Skipped $DISK_INPUT"
      continue
    fi

    EXTRA_DISKS+=("$DISK_INPUT")
    echo "Queued $DISK_INPUT for setup"
  done
fi
echo "Extra disks selected: ${EXTRA_DISKS[*]}"

read -rp "Enter username: " USERNAME
read -rp "Enter full name: " FULLNAME
read -rp "Enter hostname (e.g. arch): " HOSTNAME
read -rsp "Enter password (same for root & user): " PASSWORD
echo
read -rsp "Confirm password: " PASSWORD_CONFIRM
echo

if [[ "$PASSWORD" != "$PASSWORD_CONFIRM" ]]; then
  echo "Passwords do not match"
  exit 1
fi

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
if [[ "${#EXTRA_DISKS[@]}" -eq 0 ]]; then
  mkfs.ext4 -F "$HOME"
fi

echo "--------------------"
echo "----- Mounting -----"
echo "--------------------"
mount "$ROOT" /mnt
mkdir -p /mnt/{boot,home}
mount "$BOOT" /mnt/boot
mkdir -p /mnt/boot/EFI
mount "$EFI" /mnt/boot/EFI

if [[ "${#EXTRA_DISKS[@]}" -eq 0 ]]; then
  mount "$HOME" /mnt/home
fi

HOME_SET=false

for EXTRA_DISK in "${EXTRA_DISKS[@]}"; do
  wipefs -a "$EXTRA_DISK"
  sgdisk --zap-all "$EXTRA_DISK"

  fdisk "$EXTRA_DISK" <<EOF
g
n
1


w
EOF

  sleep 1

  if [[ "$EXTRA_DISK" == *"nvme"* ]]; then
    PART="${EXTRA_DISK}p1"
  else
    PART="${EXTRA_DISK}1"
  fi

  mkfs.ext4 -F "$PART"

  if [[ "$HOME_SET" == false ]]; then
    mkdir -p /mnt/home
    mount "$PART" /mnt/home
    HOME_SET=true
  else
    DISK_NAME=$(basename "$EXTRA_DISK")
    mkdir -p "/mnt/mnt/$DISK_NAME"
    mount "$PART" "/mnt/mnt/$DISK_NAME"
  fi
done

echo "--------------------------------------"
echo "----- Installing Base Arch Linux -----"
echo "--------------------------------------"
pacstrap /mnt base git vim linux linux-headers linux-lts linux-lts-headers linux-firmware sudo networkmanager grub efibootmgr dosfstools mtools --noconfirm --needed

echo "----------------------------"
echo "----- Generating fstab -----"
echo "----------------------------"
genfstab -U /mnt > /mnt/etc/fstab

echo "-------------------------------------------"
echo "----- Chrooting for Setting up System -----"
echo "-------------------------------------------"
set -Eeuo pipefail
trap 'echo "Error at line $LINENO"; exit 1' ERR
arch-chroot /mnt bash <<CHROOT


echo "---------------------------"
echo "----- Setting up User -----"
echo "---------------------------"

useradd -m -c "$FULLNAME" -G wheel,storage,power,audio,video "$USERNAME"
echo "root:$PASSWORD" | chpasswd
echo "$USERNAME:$PASSWORD" | chpasswd

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf

pacman -Sy --noconfirm

echo "---------------------------------------"
echo "----- Setting language and locale -----"
echo "---------------------------------------"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
timedatectl set-timezone Asia/Kolkata
timedatectl set-ntp true

echo "--------------------"
echo "----- Hostname -----"
echo "--------------------"

echo "$HOSTNAME" > /etc/hostname
cat <<HOSTS >/etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
HOSTS

echo "-----------------------------------"
echo "----- Bootloader Installation -----"
echo "-----------------------------------"
grub-install --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg

echo "-----------------------------------"
echo "----- Enabling NetworkManager -----"
echo "-----------------------------------"
systemctl enable NetworkManager
CHROOT


echo ""
echo ""
echo "Base Install Complete!"
echo "Please see the further instructions in the README file."
