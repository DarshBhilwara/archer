#!/usr/bin/env bash

echo -n "Please enter EFI partition (ex /dev/sda1 or /dev/nvme0n1p1): "
read EFI

echo -n "Please enter Boot partition (ex /dev/sda2 or /dev/nvme0n1p2) : "
read BOOT

echo -n "Please enter Root(/) partition (ex /dev/sda3 or /dev/nvme0n1p3): "
read ROOT  

echo -n "Please enter your home partition (ex /dev/sda4 or /dev/nvme0n1p4): "
read HOME 

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
pacstrap /mnt base vim sudo --noconfirm --needed 

echo "----------------------------"
echo "----- Generating fstab -----"
echo "----------------------------"
genfstab -U /mnt >> /mnt/etc/fstab

echo "----------------------------------------"
echo "----- Setting language and locale ------"
echo "----------------------------------------"

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc

echo "archlinux" > /etc/hostname
cat <<EOF > /etc/hosts
127.0.0.1	localhost
::1			localhost
127.0.1.1	archlinux.localdomain	archlinux
EOF



echo ''
echo "Base Install complete. Now use README file for further instructions."
echo ''

