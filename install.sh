date +"%H:%M:%S"

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

pacstrap -i /mnt base base-devel linux linux-lts linux-headers linux-firmware intel-ucode sudo nano git networkmanager dhcpcd pulseaudio

genfstab -U /mnt > /mnt/etc/fstab
arch-chroot /mnt passwd

while true; do
    
    echo input your username
    read username
    echo "Is this correct" $username
    
    read -p "Do you want to proceed? (y/n) " yn
    
    case $yn in
        [yY] ) echo ok, we will proceed;
		clear;
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

arch-chroot /mnt EDITOR=nano
arch-chroot /mnt nano visudo

arch-chroot /mnt nano /etc/locale.gen
arch-chroot /mnt locale-gen

while true; do
    echo please enter the language you uncommitted E.G en_GB.UTF-8
    read lang
    echo is the language right $lang
    read -p "Do you want to proceed? (y/n) " yn
    
    case $yn in
        [yY] ) echo ok, we will proceed;
		clear;
        break;;
        [nN] ) echo redo your language please;
            clear;
        continue;;
        * ) echo invalid response;;
    esac
done
arch-chroot /mnt echo 'LANG='$lang > /etc/locale.conf
arch-chroot /mnt export LANG=$lang


echo Enter the host name you would like to use
read hotname

arch-chroot /mnt echo $hostname >> /etc/hostname

arch-chroot /mnt echo '127.0.0.1    localhost
::1          localhost
127.0.1.1    swayz.localdomain   localhost' > /etc/hosts

arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/london /etc/localtime

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
sleep 10s
echo Install has finished
echo please reboot your pc and log into your new arch build ":)"
date +"%H:%M:%S"