date +"%H:%M:%S"

setfont ter-132n
timedatectl set-timezone Europe/London
timedatectl set-ntp true

cfdisk /dev/sda

lsblk

mkfs.ext4 /dev/sda5
mkfs.ext4 /dev/sda6
mkswap /dev/sda7
swapon /dev/sda7
mount /dev/sda5 /mnt
mkdir /mnt/home
mount /dev/sda6 /mnt/home

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
pacman -Sy
pacman -S pacman-contrib
rankmirrors -n 10 /etc/pacman.d/mirrorlist.bak > /etc/pacman.d/mirrorlist

pacstrap -i /mnt base base-devel linux linux-lts linux-headers linux-firmware intel-ucode sudo nano vim git neofetch networkmanager dhcpcd pulseaudio

genfstab -U /mnt > /mnt/etc/fstab
arch-chroot /mnt passwd

while true; do

echo input your username
read username
echo "Is this correct" $username

read -p "Do you want to proceed? (y/n) " yn

case $yn in 
	[yY] ) echo ok, we will proceed;
		break;;
	[nN] ) echo redo your username please;
        clear;
		continue;;
	* ) echo invalid response;;
esac

done

arch-chroot /mnt useradd -m $username
arch-chroot /mnt passwd $username
arch-chroot /mnt usermod -aG wheel,storage,power $username

arch-chroot /mnt EDITOR=nano visudo

arch-chroot /mnt nano /etc/locale.gen
arch-chroot /mnt locale-gen
arch-chroot /mnt echo LANG=en_GB.UTF-8 > /etc/locale.conf
arch-chroot /mnt export LANG=_GB.UTF-8

arch-chroot /mnt echo arch-swayz > /etc/hostname

arch-chroot /mnt nano /etc/hosts

arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/london /etc/localtime

arch-chroot /mnt mkdir /boot/efi
arch-chroot /mnt mount /dev/sda1 /boot/efi/
arch-chroot /mnt pacman -S grub efibootmgr dosfstools mtools
arch-chroot /mnt nano /etc/default/grub
arch-chroot /mnt pacman -S os-prober
arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
arch-chroot /mnt systemctl enable dhcpcd.service
arch-chroot /mnt systemctl enable NetworkManager.service
exit

echo Install has finished
echo please reboot your pc and log into your new arch build ":)"
date +"%H:%M:%S"