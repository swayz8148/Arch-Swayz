#!/bin/sh

while true; do
    clear
    read -p 'This will install a basic arch linux install do you want to continue(y/n)' yn
    
    case $yn in
        [yY])
            echo 'Starting now...'
            sleep 2s
            break
        ;;
        [nN])
            echo 'Stopping now...'
            sleep 2s
            exit
        ;;
        *) echo 'invalid respone try again!' ;;
    esac
done

echo 'Welcome to my arch linux install'
sleep 3s
clear

timedatectl set-timezone Europe/London
timedatectl set-ntp true

loadkeys uk

cfdisk

echo 'please pick the parttion you want to be the root please only include the parttion number'
read -r root
echo 'please pick the parttion you want to be the home please only include the parttion number'
read -r home
echo 'please pick the parttion you want to be the swap please only include the parttion number'
read -r swap

mkfs.ext4 /dev/sda"$root"
mkfs.ext4 /dev/sda"$home"
mkswap /dev/sda"$swap"
swapon /dev/sda"$swap"

echo 'Mounting the parttions'
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

while true; do
    echo 'please enter your username'
    read -r username
    echo "$username"
    read -p 'Is your username right (y/n)' yn
    
    case $yn in
        [yY])
            arch-chroot /mnt useradd -m "$username"
            break
        ;;
        [nN])
            echo 'Please redo your username'
            clear
            continue
        ;;
        *) echo 'invalid respone please try again!' ;;
    esac
done

arch-chroot /mnt passwd "$username"
arch-chroot /mnt usermod -aG wheel,storage,power "$username"

arch-chroot /mnt sudo nano visudo

arch-chroot /mnt nano /etc/locale.gen
arch-chroot /mnt locale-gen

while true; do
    echo 'Please enter the lang you use'
    read -r lang
    echo "$lang"
    read -p 'Is your lang right (y/n)' yn
    case $yn in
        [yY])
            arch-chroot /mnt echo LANG="$lang" > /etc/locale.conf
            export LANG="$lang"
            break
        ;;
        [nN])
            echo 'please redo your lang'
            clear
            continue
        ;;
        *) echo 'invalid respone please try again!' ;;
    esac
done

while true; do
    echo 'Please enter your hostname'
    read -r hostname
    echo "$hostname"
    read -p 'Is your hostname right (y/n)' yn
    case $yn in
        [yY])
            arch-chroot /mnt echo "$hostname" > /etc/hostname
            break
        ;;
        [nN])
            echo 'please redo your hostname'
            continue
        ;;
        *) echo 'invalid respone please try again!' ;;
    esac
done

arch-chroot /mnt touch /etc/hosts
arch-chroot /mnt echo '127.0.0.1   localhost
::1         localhost
127.0.1.1   '"$hostname"'.localdomain localhost' > /etc/hosts

while true; do
    echo 'please enter your timezone example Europe/london'
    read -r timezone
    
    echo $timezone
    read -p 'Is your timezone right (y/n)' yn
    case $yn in
        [yY])
            arch-chroot /mnt ln -sf /usr/share/zoneinfo/"$localtime" /etc/localtime
            break
        ;;
        [nN])
            echo 'Please redo your timezone'
            clear
            continue
        ;;
        *) echo 'invalid respone please try again!' ;;
    esac
done

arch-chroot /mnt mkdir /boot/efi
arch-chroot /mnt mount /dev/sda1 /boot/efi/
arch-chroot /mnt pacman -S grub efibootmgr dosfstools mtools
arch-chroot /mnt nano /etc/default/grub
arch-chroot /mnt pacman -S os-prober
arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg -home /boot/grub/grub.cfg
arch-chroot /mnt systemctl enable dhcpcd
arch-chroot /mnt systemctl enable NetworkManager
clear
echo 'You made it the install is now done have fun with archlinux'

curl -LO https://raw.githubusercontent.com/swayz8148/Arch-Swayz/main/apps.sh /mnt/home/"$username"/apps

while true; do
    read -p 'would you like to unmount and reboot now? (y/n)' yn
    case $yn in
        [yY])
            echo 'Unmounting..'
            umount -lR /mnt
            echo 'Rebooting..'
            sleep 3s
            reboot
        ;;
        [nN])
            echo 'Ok exiting the script'
            exit
        ;;
    esac
done