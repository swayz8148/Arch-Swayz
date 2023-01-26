#!/bin/sh
timedatectl set-timezone Europe/London
timedatectl set-ntp true

cfdisk /dev/sda

clear
sleep 2s

echo "--------------------------------------------------------------------------------------------------"
lsblk
echo "--------------------------------------------------------------------------------------------------"

echo "please pick the parttion you want to be the root"
read -r drive1
echo "please pick the parttion you want to be the home"
read -r drive2
echo "please pick the parttion you want to be the swap"
read -r drive3

mkfs.ext4 /dev/sda"$drive1"
mkfs.ext4 /dev/sda"$drive2"
mkswap /dev/sda"$drive3"
swapon /dev/sda"$drive3"
mount /dev/sda"$drive1" /mnt
mkdir /mnt/home
mount /dev/sda"$drive2" /mnt/home

clear
sleep 2s

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
pacman -Sy
pacman -S pacman-contrib
rankmirrors -n 10 /etc/pacman.d/mirrorlist.bak >/etc/pacman.d/mirrorlist

pacstrap -i /mnt base base-devel linux linux-lts linux-headers linux-firmware intel-ucode sudo nano git networkmanager dhcpcd pulseaudio

genfstab -U /mnt >/mnt/etc/fstab
arch-chroot /mnt passwd

clear
sleep 2s

while true; do
    echo input your username
    read -r username
    echo "Is this correct $username"
    read -p "Do you want to proceed? (y/n) " yn

    case $yn in
    [yY])
        clear
        break
        ;;
    [nN])
        clear
        continue
        ;;
    *) echo invalid response ;;
    esac
done

clear
sleep 2s

arch-chroot /mnt useradd -m "$username"
arch-chroot /mnt passwd "$username"
arch-chroot /mnt usermod -aG wheel,storage,power "$username"

arch-chroot /mnt sudo EDITOR=nano visudo
clear

arch-chroot /mnt nano /etc/locale.gen
arch-chroot /mnt locale-gen

while true; do
    echo please enter the language you uncommitted E.G en_GB.UTF-8
    read -r lang
    echo is the language right "$lang"
    read -p "Do you want to proceed? (Y/n) " Yn

    case $Yn in
    [yY])
        clear
        break
        ;;
    [nN])
        clear
        continue
        ;;
    *) echo invalid response ;;
    esac
done

arch-chroot /mnt echo "LANG="$lang > /etc/locale.conf
arch-chroot /mnt export "LANG="$lang

clear
sleep 2s



while true; do
    echo Enter the host name you would like to use
    read -r hostname
    echo is the hostname right "$hostname"
    read -p "Do you want to proceed? (Y/n) " Yn

    case $Yn in
    [yY])
        clear
        break
        ;;
    [nN])
        clear
        continue
        ;;
    *) echo invalid response ;;
    esac
done

arch-chroot /mnt echo "$hostname" > /etc/hostname

arch-chroot /mnt echo '127.0.0.1    localhost
::1          localhost
127.0.1.1    '$hostname'.localdomain   localhost' >/etc/hosts

arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/london /etc/localtime

clear
sleep 2s

arch-chroot /mnt mkdir /boot/efi
arch-chroot /mnt mount /dev/sda1 /boot/efi/
arch-chroot /mnt pacman -S grub efibootmgr dosfstools mtools
arch-chroot /mnt nano /etc/default/grub
arch-chroot /mnt pacman -S os-prober
arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
clear
arch-chroot /mnt systemctl enable dhcpcd
arch-chroot /mnt systemctl enable NetworkManager
echo "Install has finished"
echo "please reboot your pc and log into your new arch build :)"
date +"%H:%M:%S"
