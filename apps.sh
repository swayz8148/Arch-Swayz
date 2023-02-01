#!/bin/sh
setxkbmap gb
sudo pacman -S pavucontrol thunar ranger code discord spotify-launcher unzip gedit bitwarden nvidia nvidia-utils nvidia-settings cmatrix zsh ntfs-3g pulseaudio-equalizer-ladspa xorg-xsetroot direnv 
echo "waiting 5 seconds..."
sleep 5s
mkdir Stuff
cd Stuff || exit
git clone https://aur.archlinux.org/brave-bin.git
git clone https://aur.archlinux.org/nitch.git
git clone https://aur.archlinux.org/pipes.sh.git
git clone https://aur.archlinux.org/nodejs-nativefier.git
git clone https://aur.archlinux.org/whatsapp-nativefier.git
git clone https://aur.archlinux.org/netflix-nativefier.git
git clone https://aur.archlinux.org/snapchat-nativefier.git
git clone https://aur.archlinux.org/cava.git