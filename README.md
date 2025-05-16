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
Suggested for 1tb drive
- 2GB EFI System for EFI
- 2GB Linux Filesystem for boot
- 180GB Linux Filesystem for root
- rest Linux Filesystem for home

## Installing the System
```
pacman -Sy git
git clone https://github.com/DarshBhilwara/archer.git
cd archer
chmod +x base.sh
./base.sh
```

## Miscellaneous
- Brave://flags and turn on ozone wayland
- Make swap file(size=ram+2)  <https://www.youtube.com/watch?v=HSbBl31ohjE>
- Set color theme (currently using kanagawa and dracula combined).

