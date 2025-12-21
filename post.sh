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
trap 'echo "Error at line $LINENO: command failed." >&2; exit 1' ERR

cd "$HOME"

echo "----------------------------"
echo "----- Swap File Setup -----"
echo "----------------------------"

read -rp "Do you want to create a swap file? [Y/n]: " CREATE_SWAP
CREATE_SWAP=${CREATE_SWAP,,}
CREATE_SWAP=${CREATE_SWAP:-y}

if [[ "$CREATE_SWAP" == "y" || "$CREATE_SWAP" == "yes" ]]; then
  echo "Suggested swap size: RAM + 2G (example: 18G for 16G RAM)"
  read -rp "Enter swap size : " SWAP_SIZE

  if [[ -z "$SWAP_SIZE" ]]; then
    echo "No swap size entered, skipping swap setup."
  elif [[ -f /swapfile ]]; then
    echo "/swapfile already exists, skipping creation."
  else
    echo "Creating swapfile of size $SWAP_SIZE..."

    sudo fallocate -l "$SWAP_SIZE" /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile

    echo "/swapfile none swap defaults 0 0" | sudo tee -a /etc/fstab
  fi
else
  echo "Skipping swap file setup."
fi


echo "-------------------------"
echo "----- System Update -----"
echo "-------------------------"
sudo pacman -Syu 


echo "-------------------------------"
echo "----- CPU Microcode -----"
echo "-------------------------------"
echo "Select your CPU type:"
echo "1) Intel"
echo "2) AMD"
echo "3) None"
read -rp "Enter choice [1-3]: " ucode_choice

ucode_pkg=""
case "$ucode_choice" in
  1) ucode_pkg="intel-ucode" ;;
  2) ucode_pkg="amd-ucode" ;;
  3) echo "Skipping microcode." ;;
  *) echo "Invalid -> skipping microcode." ;;
esac

echo "-----------------------"
echo "----- GPU Drivers -----"
echo "-----------------------"
echo "Select your GPU type:"
echo "1) Intel"
echo "2) NVIDIA"
echo "3) AMD"
echo "4) None"
read -rp "Enter number [1-4]: " gpu

gpu_packages=""
case "$gpu" in
  1) gpu_packages="mesa xf86-video-intel vulkan-intel" ;;
  2) gpu_packages="nvidia-open nvidia-open-lts nvidia-utils nvidia-settings linux-firmware-nvidia" ;;
  3) gpu_packages="mesa xf86-video-amdgpu vulkan-radeon" ;;
  4) gpu_packages="" ;;
  *) echo "Invalid -> no GPU drivers." ;;
esac

echo "Do you want a full or minimal install?"
echo "1) Full"
echo "2) Minimal"
read -rp "Enter choice [1/2]: " full_min

if [[ "$full_min" == "1" ]]; then
  base_packages="wireless_tools pipewire-pulse nano starship unzip wpa_supplicant dialog kitty hyprland ripgrep nautilus waybar firefox neovim nwg-look qt5ct qt6ct qt5-wayland xdg-desktop-portal-hyprland python-virtualenv audacity python-pipenv pipewire wireplumber qt6-wayland gimp hyprpolkitagent gnome-text-editor texlive libreoffice-fresh sonic-visualiser yazi figlet fastfetch htop btop gvfs-mtp brightnessctl bluez bluez-utils blueman gtk3 gtk4 dunst qt6-svg qt6-declarative rofi-wayland bash-completion gnome-calculator telegram-desktop eog evince qbittorrent nm-connection-editor qt5 qt6 vlc mpv yt-dlp wine gnome-disk-utility openshot ntfsprogs inkscape spotify-launcher plocate man net-tools dhclient bind traceroute ttf-droid otf-droid-nerd ttf-nerd-fonts-symbols rofimoji noto-fonts-emoji wtype bat tree jdk-openjdk hyprlock hypridle ffmpegthumbnailer scrcpy gnome-keyring libsecret seahorse helvum android-tools ttf-dejavu ifuse libimobiledevice usbmuxd gvfs-afc remmina qemu libvirt virt-manager edk2-ovmf dnsmasq vde2 bridge-utils nwg-displays "
  aur_packages="brave-bin firefox-beta-bin visual-studio-code-bin hyprpicker hyprshot hyprpaper wlogout bottles ani-cli webcord hyprsunset android-sdk-platform-tools github-desktop dracula-cursors-git dracula-icons-git cloudflare-warp-bin google-earth-pro"
else
  base_packages="base-devel dosfstools grub efibootmgr mtools wireless_tools sudo linux linux-headers pipewire-pulse networkmanager linux-firmware linux-lts linux-lts-headers nano starship unzip wpa_supplicant dialog os-prober kitty hyprland ripgrep nautilus waybar git neovim nwg-look qt5ct qt6ct qt5-wayland xdg-desktop-portal-hyprland python-virtualenv python-pipenv pipewire wireplumber qt6-wayland hyprpolkitagent yazi figlet fastfetch htop btop gvfs-mtp brightnessctl bluez bluez-utils blueman gtk3 gtk4 dunst qt6-svg qt6-declarative rofi-wayland bash-completion eog evince nm-conn # dwindleection-editor qt5 qt6 vlc mpv yt-dlp wine gnome-disk-utility ntfsprogs plocate man net-tools dhclient bind traceroute ttf-droid otf-droid-nerd ttf-nerd-fonts-symbols rofimoji noto-fonts-emoji wtype bat tree jdk-openjdk hyprlock hypridle ffmpegthumbnailer scrcpy gnome-keyring seahorse libsecret helvum android-tools ttf-dejavu ifuse libimobiledevice usbmuxd gvfs-afc nwg-displays"
  aur_packages="hyprpicker hyprshot hyprpaper wlogout ani-cli hyprsunset android-sdk-platform-tools dracula-cursors-git dracula-icons-git"
fi

echo "Do you want to install cybersecurity tools?"
echo "1) Yes"
echo "2) No"
read -rp "Enter choice [1/2]: " cybersec_choice

cybersec_packages=""
cybersec_aur=""
if [[ "$cybersec_choice" == "1" ]]; then
  cybersec_packages="nuclei gf gau amass httpx dirsearch eyewitness retire trufflehog gitrob altdns sublist3r recon-ng seclists ffuf sherlock netcat whois openvpn wireshark-qt wireshark-cli nmap subfinder gobuster"
  cybersec_aur="burpsuite caido-desktop rockyou hakrawler-git"
else
  echo "No cybersec packages will be installed."
fi

sudo pacman -S $base_packages $gpu_packages $ucode_pkg


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
yay -S $aur_packages $cybersec_aur

echo "----------------------------"
echo "----- Getting Dotfiles -----"
echo "----------------------------"
git clone https://github.com/DarshBhilwara/dotfiles.git
cd dotfiles
mv * "$HOME/.config/" || true
cd ..
rm -rf dotfiles
echo 'source ~/.config/terminal/bashrc' >> "$HOME/.bashrc"

sudo sed -i 's/^#HandlePowerKey=.*/HandlePowerKey=suspend/' /etc/systemd/logind.conf
sudo sed -i 's/^HandlePowerKey=.*/HandlePowerKey=suspend/' /etc/systemd/logind.conf
if [[ -f /etc/spotify-launcher.conf ]]; then
    sudo sed -i 's/^#\(extra_arguments=.*--enable-features=UseOzonePlatform.*\)/\1/' /etc/spotify-launcher.conf
fi

if [[ "$cybersec_choice" == "1" ]]; then
  echo "-------------------------------------------------"
  echo "----- Installing Blackarch and its Packages -----"
  echo "-------------------------------------------------"
  curl -fsSL -O https://blackarch.org/strap.sh
  chmod +x strap.sh
  sudo ./strap.sh || { echo "Error: BlackArch bootstrap failed"; exit 1; }
  sudo pacman -Syu
  sudo pacman -S $cybersec_packages
fi


echo "-----------------------------"
echo "----- Enabling Services -----"
echo "-----------------------------"
sudo systemctl enable bluetooth.service 
sudo systemctl enable libvirtd.service
sudo usermod -aG libvirt "$USER"

echo ""
echo ""
echo "Install complete. You should reboot and read the README file for further instructions."

