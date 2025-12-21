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

## Installing the System
```bash
pacman -Sy git
git clone https://github.com/DarshBhilwara/archer.git
cd archer
chmod +x base.sh
./base.sh
```
## Suggested disk setup for a single 1tb drive
- 2GB for EFI
- 2GB for boot
- 180GB for root

## Suggest disk setup for multiple disks
### First Disk
- 2GB for EFI
- 2GB for boot
- Rest for root
### Second Disk
- Full for home
### Other disks
- Will be mounted on /mnt

## After base.sh
```bash
exit
umount -a
reboot
```

## After reboot
- Now your base Archlinux is installed
- For GUI and other packages and settings, you need to install `post.sh`
- First connect to internet using `nmtui`
```bash
mkdir .config
cd .config
git clone https://github.com/DarshBhilwara/archer.git
cd archer
chmod +x post.sh
./post.sh 
```

## Miscellaneous
- For checking system binds and softwares, you can see them in .config
- Brave://flags and turn on ozone wayland
- Set color theme (currently using kanagawa and dracula combined).
- Install some more cybersec tools - commonspeak2, burpsuite
