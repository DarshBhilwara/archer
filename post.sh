#!/bin/bash

echo -n "Please enter EFI partition (ex /dev/sda1 or /dev/nvme0n1p1): "
read EFI


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


echo "-------------------------------"
echo "----- Installing Packages -----"
echo "-------------------------------"
sudo pacman -Sy
sudo pacman -Syyu
sudo pacman -S base-devel dosfstools grub efibootmgr mtools sudo linux linux-headers pipewire-pulse networkmanager linux-firmware linux-lts linux-lts-headers wireless_tools nano starship unzip amd-ucode wpa_supplicant dialog os-prober kitty hyprland nautilus waybar firefox sddm git neovim nwg-look qt5ct qt6ct qt5-wayland xdg-desktop-portal-hyprland pipewire wireplumber qt6-wayland polkit-kde-agent wireshark-qt wireshark-cli vifm figlet fastfetch htop btop gvfs-mtp brightnessctl bluez bluez-utils blueman gtk3 gtk4 dunst qt6-svg qt6-declarative rofi-wayland bash-completion telegram-desktop virtualbox virtualbox-host-modules-arch eog evince qbittorrent nm-connection-editor qt5 qt6 vlc mpv yt-dlp wine gnome-disk-utility ntfsprogs inkscape spotify-launcher plocate man net-tools dhclient bind nmap traceroute ttf-droid otf-droid-nerd ttf-nerd-fonts-symbols rofimoji noto-fonts-emoji wtype bat tree jdk-openjdk hyprlock hypridle scrcpy gnome-keyring helvum android-tools --noconfirm --needed


echo "------------------------------------"l
echo "----- Bootloader Installation ------"
echo "------------------------------------"
sudo mkdir /boot/EFI
sudo mount "${EFI}" /boot/EFI 
sudo grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
sudo grub-mkconfig -o /boot/grub/grub.cfg



echo "------------------------------"
echo "----- Getting AUR Helper -----"
echo "------------------------------"
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay 

echo "-----------------------------------"
echo "----- Installing AUR packages -----"
echo "-----------------------------------"
yay -S brave-bin firefox-beta-bin visual-studio-code-bin hyprpicker hyprshot hyprpaper wlogout bottles gimp-devel ani-cli webcord hyprsunset sddm-theme-catppuccin android-sdk-platform-tools github-desktop

#Dotfiles
echo "----------------------------"
echo "----- Getting Dotfiles -----"
echo "----------------------------"
git clone https://github.com/DarshBhilwara/dotfiles.git
cd dotfiles
mv * $HOME/.config/
cd ..
rm -rf dotfiles

echo "-------------------------"
echo "----- Setting Time ------"
echo "-------------------------"
timedatectl set-timezone Asia/Kolkata

#Services 
echo "-----------------------------"
echo "----- Enabling Services -----"
echo "-----------------------------"
sudo systemctl enable NetworkManager.service
sudo systemctl enable sddm.service 
sudo systemctl enable bluetooth.service

echo ''
echo "Install complete. You should reboot and read the README file for further instructions."
echo ''
