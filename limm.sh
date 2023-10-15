#!/bin/bash
read -p 'what disk are you installing to? (ex: /dev/sdx): ' disk
set -e
echo "g
n
p
1

+512M
n
p
2


w" | fdisk $disk
echo "relax"
mkfs.ext4 ${disk}2
mkfs.vfat -F32 ${disk}1
mount ${disk}2 /mnt
mkdir /mnt/boot
mount ${disk}1 /mnt/boot

echo "relax"
#installs base system and networking
pacstrap /mnt base base-devel linux linux-firmware dhcpcd networkmanager
echo "done fetching"

#generates fstab
genfstab -U /mnt >> /mnt/etc/fstab

#chroots into root
arch-chroot /mnt /bin/bash <<EOF

#installs grub
pacman -S --noconfirm grub

#links timezone to local time
ls /usr/share/zoneinfo/
echo 'set up your timezone'
read -p 'in what part of the world do you live in? (ex: America): ' dir1
ls /usr/share/zoneinfo/${dir1}/
read -p 'where do you live? (ex: New_York' dir2
echo your timezone will be set as ${dir1}/${dir2}
ln -sf /usr/share/zoneinfo/${dir1}/${dir2} /etc/localtime  
hwclock --systohc

#sets up locales and keyboard
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=sv-latin1" > /etc/vconsole.conf
locale-gen

#choose hostname
read -p 'what do you want your hostname to be?: ' hostname
echo "${hostname}" >> /etc/hostname

#generates an initramfs
mkinitcpio -P

#enables networking on boot
systemctl enable dhcpcd
systemctl enable NetworkManager

#installs grub
pacman -S --noconfirm grub
grub-install --target=x86_64-efi --efi-directory=/boot/ --bootloader-id=Nuclearthreat
grub-mkconfig -o /boot/grub/grub.cfg

read -p 'do you want to install any other packages? (y/n): ' paconfirm

if [ $paconfirm = 'y' ]
then
	read -p 'which packages do you want to install?: ' packages
	pacman -S $packages
else
	echo 'ok'
fi

read -p 'do you want to set a password for the root account? (y/n): ' password

if [ $password = 'y' ]
then
	passwd
else
	echo 'ok'
fi

read -p 'do you want to make additional changes to the system? (y/n): ' changes

if [ $changes = 'y' ]
then
	exit 1
else
	echo 'ok'
fi

echo 'exiting...'
EOF
echo -e "\e[91mDont forget to set passwd if you already havent\e[0m"
echo -e "additionally use \e[91mumount -R /mnt\e[0m"
