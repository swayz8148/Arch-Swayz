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

pacstrap -i /mnt base base-devel linux linux-lts linux-headers linux-firmware intel-ucode
sudo nano vim git neofetch networkmanager dhcpcd pulseaudio

genfstab -U /mnt > /mnt/etc/fstab
arch-chroot /mnt
passwd

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

useradd -m $username
passwd $username
usermod -aG wheel,storage,power $username

EDITOR=nano visudo

nano /etc/locale.gen
locale-gen
echo LANG=en_GB.UTF-8 > /etc/locale.conf
export LANG=_GB.UTF-8

echo arch-swayz > /etc/hostname

nano /etc/hosts

ln -sf /usr/share/zoneinfo/Europe/london /etc/localtime

mkdir /boot/efi
mount /dev/sda1 /boot/efi/
pacman -S grub efibootmgr dosfstools mtools
nano /etc/default/grub
pacman -S os-prober
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable dhcpcd.service
systemctl enable NetworkManager.service
exit

echo Install has finished
echo please reboot your pc and log into your new arch build ":)"
date +"%H:%M:%S"