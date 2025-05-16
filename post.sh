#!/bin/bash

cd 
echo "-------------------------------"
echo "----- Installing Packages -----"
echo "-------------------------------"
sudo pacman -Sy
sudo pacman -Syyu

echo "Select your CPU type:"
echo "1) Intel"
echo "2) AMD"
echo "3) None"

read -rp "Enter choice [1-3]: " ucode_choice

ucode_pkg=""

case "$ucode_choice" in
  1)
    echo "Intel ucode."
    ucode_pkg="intel-ucode"
    ;;
  2)
    echo "AMD ucode."
    ucode_pkg="amd-ucode"
    ;;
  3)
    echo "Skipping ucode installation."
    ;;
  *)
    echo "Invalid (skipping ucode installation)"
    ;;
esac


echo "Select your GPU type:"
echo "1) Intel"
echo "2) NVIDIA"
echo "3) AMD"
echo "4) None / Virtual Machine / Other"

read -rp "Enter number [1-4]: " gpu

gpu_packages=""

case "$gpu" in
  1)
    echo "Intel GPU"
    gpu_packages="mesa xf86-video-intel vulkan-intel"
    ;;
  2)
    echo "NVIDIA GPU"
    gpu_packages="nvidia nvidia-utils nvidia-settings"
    ;;
  3)
    echo "AMD GPU"
    gpu_packages="mesa xf86-video-amdgpu vulkan-radeon"
    ;;
  4)
    echo "No GPU-specific drivers."
    gpu_packages=""
    ;;
  *)
    echo "Invalid (No GPU-specific drivers)"
    gpu_packages=""
    ;;
esac
full_min=""
echo "Do you want a full or a minimal install?"
echo "1) Full"
echo "2) Minimal"
read -rp "Enter choice [1/2]: " full_min

case $full_min in 
  2)
    echo "Minimal"
    base_packages="base-devel dosfstools grub efibootmgr mtools wireless_tools sudo linux linux-headers pipewire-pulse networkmanager linux-firmware linux-lts linux-lts-headers nano starship unzip wpa_supplicant dialog os-prober kitty hyprland ripgrep nautilus waybar sddm git neovim nwg-look qt5ct qt6ct qt5-wayland xdg-desktop-portal-hyprland python-virtualenv python-pipenv pipewire wireplumber qt6-wayland hyprpolkitagent yazi figlet fastfetch htop btop gvfs-mtp brightnessctl bluez bluez-utils blueman gtk3 gtk4 dunst qt6-svg qt6-declarative rofi-wayland bash-completion eog evince nm-connection-editor qt5 qt6 vlc mpv yt-dlp wine gnome-disk-utility ntfsprogs plocate man net-tools dhclient bind traceroute ttf-droid otf-droid-nerd ttf-nerd-fonts-symbols rofimoji noto-fonts-emoji wtype bat tree jdk-openjdk hyprlock hypridle ffmpegthumbnailer scrcpy gnome-keyring helvum android-tools"
    aur_packages=hyprpicker hyprshot hyprpaper wlogout ani-cli hyprsunset sddm-theme-catppuccin android-sdk-platform-tools dracula-cursors-git dracula-icons-git

    ;;
  1)
    echo "Full"
    base_packages="base-devel dosfstools grub efibootmgr mtools wireless_tools sudo linux linux-headers pipewire-pulse networkmanager linux-firmware linux-lts linux-lts-headers nano starship unzip wpa_supplicant dialog os-prober kitty hyprland ripgrep nautilus waybar firefox sddm git neovim nwg-look qt5ct qt6ct qt5-wayland xdg-desktop-portal-hyprland python-virtualenv audacity python-pipenv pipewire wireplumber qt6-wayland gimp hyprpolkitagent gnome-text-editor libreoffice-fresh sonic-visualiser yazi figlet fastfetch htop btop gvfs-mtp brightnessctl obs-studio bluez bluez-utils blueman gtk3 gtk4 dunst qt6-svg qt6-declarative rofi-wayland bash-completion gnome-calculator telegram-desktop eog evince qbittorrent nm-connection-editor qt5 qt6 vlc mpv yt-dlp wine gnome-disk-utility openshot ntfsprogs inkscape spotify-launcher plocate man net-tools dhclient bind traceroute ttf-droid otf-droid-nerd ttf-nerd-fonts-symbols rofimoji noto-fonts-emoji wtype bat tree jdk-openjdk hyprlock hypridle ffmpegthumbnailer scrcpy gnome-keyring helvum android-tools"
    aur_packages=brave-bin firefox-beta-bin visual-studio-code-bin hyprpicker hyprshot hyprpaper wlogout bottles ani-cli webcord hyprsunset sddm-theme-catppuccin android-sdk-platform-tools github-desktop dracula-cursors-git dracula-icons-git cloudflare-warp-bin
    ;;
  *)
    echo "Invalid (Minimal)"
    base_packages="base-devel dosfstools grub efibootmgr mtools wireless_tools sudo linux linux-headers pipewire-pulse networkmanager linux-firmware linux-lts linux-lts-headers nano starship unzip wpa_supplicant dialog os-prober kitty hyprland ripgrep nautilus waybar sddm git neovim nwg-look qt5ct qt6ct qt5-wayland xdg-desktop-portal-hyprland python-virtualenv python-pipenv pipewire wireplumber qt6-wayland hyprpolkitagent yazi figlet fastfetch htop btop gvfs-mtp brightnessctl bluez bluez-utils blueman gtk3 gtk4 dunst qt6-svg qt6-declarative rofi-wayland bash-completion eog evince nm-connection-editor qt5 qt6 vlc mpv yt-dlp wine gnome-disk-utility ntfsprogs plocate man net-tools dhclient bind traceroute ttf-droid otf-droid-nerd ttf-nerd-fonts-symbols rofimoji noto-fonts-emoji wtype bat tree jdk-openjdk hyprlock hypridle ffmpegthumbnailer scrcpy gnome-keyring helvum android-tools"
    aur_packages=hyprpicker hyprshot hyprpaper wlogout ani-cli hyprsunset sddm-theme-catppuccin android-sdk-platform-tools dracula-cursors-git dracula-icons-git
    ;;
esac

echo "Do you want to install cybersecurity tools?"
echo "1) Yes"
echo "2) No"
read -rp "Enter choice [1/2]: " cybersec_choice

cybersec_packages=""
case $cybersec_choice in 
  1)
    echo "Cybersec Packages will be installed"
    curl -O https://blackarch.org/strap.sh
    chmod +x strap.sh
    ./strap.sh
    pacman -Syu --noconfirm
    cybersec_packages="wireshark-qt wireshark-cli virtualbox virtualbox-host-modules-dkms nmap"
    ;;
  2)
    echo "No cybersec packages will be installed"
    cybersec_packages=""
    ;;
  *)
    echo "Invalid (no cybersec packages will be installed)"
    cybersec_packages=""
    ;;
esac


sudo pacman -S --noconfirm --needed $base_packages $gpu_packages $cybersec_packages $ucode_pkg



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
yay -S $aur_packages 

echo "----------------------------"
echo "----- Getting Dotfiles -----"
echo "----------------------------"
git clone https://github.com/DarshBhilwara/dotfiles.git
cd dotfiles
mv * $HOME/.config/
cd ..
rm -rf dotfiles
echo 'source ~/.config/terminal/bashrc' >> "$HOME/.bashrc"
sudo sed -i 's/^#HandlePowerKey=.*/HandlePowerKey=suspend/' /etc/systemd/logind.conf
sudo sed -i 's/^HandlePowerKey=.*/HandlePowerKey=suspend/' /etc/systemd/logind.conf
if [[ -f /etc/spotify-launcher.conf ]]; then
    sudo sed -i 's/^#\(extra_arguments=.*--enable-features=UseOzonePlatform.*\)/\1/' /etc/spotify-launcher.conf
fi


echo "-----------------------------"
echo "----- Enabling Services -----"
echo "-----------------------------"
sudo systemctl enable NetworkManager.service
sudo systemctl enable sddm.service 
sudo systemctl enable bluetooth.service
sudo systemctl enable systemd-timesyncd.service

echo "Cleaning up post-install scripts..."
rm -f ~/post.sh
sudo rm -f /root/user.sh

echo ''
echo "Install complete. You should reboot and read the README file for further instructions."
echo ''
