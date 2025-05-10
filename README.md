# About
This is my arch installation process.

## Create Arch ISO
Create a bootable usb with arch installation image from <https://archlinux.org/download/> and boot in the live environment.

## Set up network 
- rfkill list 
- rfkill unblock {device name} 
- iwctl device list 
- iwctl device {device name} set-property Powered on 
- iwctl station {device name} scan 
- iwctl station {device name} connect {wifi name} 

## Setting up disk
Use fdisk to partition disk like (suitable for 1tb drive)
- 2GB EFI System for EFI
- 2GB Linux Filesystem for boot
- 180GB Linux Filesystem for root
- rest Linux Filesystem for home

## Installing the Base System
```
pacman -Sy git
git clone https://github.com/DarshBhilwara/archer.git
cd archer
chmod +x base.sh
./base.sh
```
## Setting User 
```
arch-chroot /mnt
useradd -m {username}
usermod -c "{user}" {username}
usermod -aG wheel,storage,power,audio,video {username}
passwd (and set root password)
visudo (and remove #from # %wheel ALL=(ALL:ALL) ALL )
passwd {username} (and set user password)
su {username}
enable multilib in /etc/pacman.conf
cd /home/{username}
```

## Installing Full System
```
git clone https://github.com/DarshBhilwara/archer.git
cd archer
chmod +x post.sh
./post.sh
```

## Miscellaneous
- install graphic drivers <https://wiki.hyprland.org/Nvidia/>
- Brave://flags and turn on ozone wayland
- Make swap file(size=ram+2)  <https://www.youtube.com/watch?v=HSbBl31ohjE>
- In .bashrc add a line - source ~/.config/terminal/bashrc
- In /etc/systemd/logind.conf set HandlePowerKey=suspend
- Remove # from extra arguments for wayland line from /etc/spotify-launcher.conf
- Set color theme (currently using kanagawa and dracula combined).

