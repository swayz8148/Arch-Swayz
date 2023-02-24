#!/bin/bash

# Set up disk partitions
parted /dev/sda mklabel gpt
parted /dev/sda mkpart ESP fat32 1MiB 513MiB
parted /dev/sda set 1 boot on
parted /dev/sda mkpart primary ext4 513MiB 100%
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

# Install essential packages
pacstrap /mnt base linux linux-firmware efibootmgr

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the installed system
arch-chroot /mnt

# Set timezone
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

# Set up localization
echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8" > /etc/locale.conf

# Set up network
echo "myhostname" > /etc/hostname
echo "127.0.0.1 localhost" > /etc/hosts
echo "::1 localhost" >> /etc/hosts
systemctl enable dhcpcd.service

# Install bootloader
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub --recheck
grub-mkconfig -o /boot/grub/grub.cfg

# Exit chroot and unmount partitions
exit
umount -R /mnt

# Reboot
reboot