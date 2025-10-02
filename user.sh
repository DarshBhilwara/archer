#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "Error at line $LINENO: command failed." >&2; exit 1' ERR

EFI=$(cat /root/.efi_partition)

echo "---------------------------"
echo "----- Setting up User -----"
echo "---------------------------"
read -rp "Enter new username: " USERNAME
read -rp "Enter full name for the user: " FULLNAME

useradd -m "$USERNAME"
usermod -c "$FULLNAME" "$USERNAME"
usermod -aG wheel,storage,power,audio,video "$USERNAME"

echo "Set root password:"
passwd
echo "Set password for $USERNAME:"
passwd "$USERNAME"

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf

echo "---------------------------------------"
echo "----- Setting language and locale -----"
echo "---------------------------------------"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc

echo "archlinux" > /etc/hostname
cat <<EOF >/etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   archlinux.localdomain archlinux
EOF

systemctl daemon-reexec || true
timedatectl set-timezone Asia/Kolkata
timedatectl set-ntp true

echo "-----------------------------------"
echo "----- Bootloader Installation -----"
echo "-----------------------------------"
pacman -Sy --noconfirm grub efibootmgr dosfstools os-prober mtools
mkdir -p /boot/EFI
mount "$EFI" /boot/EFI
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg

echo "---------------------------"
echo "----- Running post.sh -----"
echo "---------------------------"
mv /root/post.sh "/home/$USERNAME/post.sh"
chmod +x "/home/$USERNAME/post.sh"
chown "$USERNAME:$USERNAME" "/home/$USERNAME/post.sh"

echo "Change user to $USERNAME and run post.sh script"
sudo -i -u "$USERNAME" bash "/home/$USERNAME/post.sh"  
rm -f "/home/$USERNAME/post.sh"

echo ''
echo "Install complete. You should reboot and read the README file for further instructions."
echo ''