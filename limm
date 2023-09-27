#!/bin/bash

set -e
echo "g
n
p
1

+512M
n
p
2


w" | fdisk $1
echo "relax"
mkfs.ext4 ${1}2
mkfs.vfat -F ${1}1
mount ${1}2 /mnt
mkdir /mnt/boot
mount ${1}1 /mnt/boot

echo "relax"
pacstrap /mnt base base-devel linux linux-firmware

echo "done fetching"

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash <<EOF

pacman -S --noconfirm grub
echo "timezones"
ln -sf /usr/share/zoneinfo/Sweden/Stockholm /etc/localtime  
hwclock --systohc

locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=sv-latin1" > /etc/vconsole.conf
echo "Manifestation" > /etc/hostname

systemctl enable dhcpcd@eth0.service
grub-install --target=x86_64-efi --efi-directory=/boot/grub --bootloader-id=Nuclearthreat
grub-mkconfig -o /boot/grub/grub.cfg

EOF
echo -e "\e[91mDont forget to set passwd\e[0m"
echo -e "additionally use \e[91mumount -R /mnt\e[0m"
