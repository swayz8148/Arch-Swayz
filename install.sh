#!/bin/sh
while true; do
    read -p 'Welcome to my archlinux installer would you like to continue with the install (y/n)' yn
    
    case $yn in
        [yY])
            echo 'Starting now'
            sleep 3s
            clear
            break
        ;;
        [nN])
            echo 'Leaving now'
            sleep 1s
            clear
            break
        ;;
    esac
done

echo "
.--.
|__| .---------.
|=.| |.-------.|
|--| || Swayz ||
|  | |'-------'|
|__|~')_______('
"

echo 'This install is for windows dual boot if you are not dual booting this may not work'

echo 'Please enter your keymap if you dont know this then please go find it (can be found by using the arch wiki)'
read -r keymap

echo 'Please enter your name for the install'
read -r username
echo 'Please enter your hostname'
read -r hostname

loadkeys "$keymap"

cfdisk

echo 'please pick the partition you want to be the root please only include the partition number'
read -r root
echo 'please pick the partition you want to be the home please only include the partition number'
read -r home
echo 'please pick the partition you want to be the swap please only include the partition number'
read -r swap

mkfs.ext4 /dev/sda"$root"
mkfs.ext4 /dev/sda"$home"
mkswap /dev/sda"$swap"
swapon /dev/sda"$swap"

mount /dev/sda"$root" /mnt
mkdir /mnt/home
mount /dev/sda"$home" /mnt/home

clear

while true; do
    read -p 'Would you like to setup the fasted mirrors? (y/n)' yn
    
    case $yn in
        [yY])
            echo 'Setting up fastest mirrors'
            cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
            pacman -Syy pacman-contrib
            rankmirrors -n 10 /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist
            echo 'Fastest mirrors set'
            break
        ;;
        [nN])
            break
        ;;
        *) echo 'invalid respone please try again!' ;;
    esac
done
clear
while true; do
    read -p 'Would you like to install neofetch and vim with your base system (y/n)' yn
    
    case $yn in
        [yY])
            echo 'Install base system with neofetch and vim'
            pacstrap -i /mnt base base-devel intel-ucode sudo nano vim neofetch networkmanager dhcpcd pulseaudio
            break
        ;;
        [nN])
            echo 'Install base system without neofetch and vim'
            pacstrap -i /mnt base base-devel linux intel-ucode sudo nano networkmanager dhcpcd pulseaudio
            break
        ;;
        *) echo 'invalid respone please try again!' ;;
    esac
done
clear
genfstab -U /mnt > /mnt/etc/fstab
echo 'Setup your root password'
arch-chroot /mnt passwd

arch-chroot /mnt useradd -m "$username"
arch-chroot /mnt passwd "$username"
arch-chroot /mnt usermod -aG wheel,storage,power "$username"
arch-chroot /mnt EDITOR=nano visudo

clear

arch-chroot /mnt nano /etc/locale.gen
arch-chroot /mnt locale-gen

echo 'Enter the language you just uncommitted'
read -r lang

arch-chroot /mnt echo LANG="$lang" > /etc/locale.conf
arch-chroot /mnt export LANG="$lang"

echo 'Please enter your hostname'
echo "$hostname" > /etc/hostname

arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

arch-chroot /mnt mkdir /boot/efi
arch-chroot /mnt mount /dev/sda1 /boot/efi/
arch-chroot /mnt pacman -S grub efibootmgr dosfstools mtools
arch-chroot /mnt nano /etc/default/grub
arch-chroot /mnt pacman -S os-prober
arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
arch-chroot /mnt systemctl enable dhcpcd
arch-chroot /mnt systemctl enable NetworkManager

echo 'Rebooting...'
sleep 2s
umount -lR /mnt
reboot
