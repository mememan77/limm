#!/bin/bash
#makes partitions (execute limm.sh with disk specified ex= ./limm.sh /dev/sdx)
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
mkfs.vfat -F32 ${1}1
mount ${1}2 /mnt
mkdir /mnt/boot
mount ${1}1 /mnt/boot

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
echo "timezones"

#links timezone to local time
ln -sf /usr/share/zoneinfo/Sweden/Stockholm /etc/localtime  
hwclock --systohc

#sets up locales and keyboard
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=sv-latin1" > /etc/vconsole.conf
echo "Manifestation" > /etc/hostname
locale-gen

#makes your hostname "archlinux" (change this if you want)
echo "archlinux" >> /etc/hostname

#generates an initramfs
mkinitcpio -P

#enables networking on boot
systemctl enable dhcpcd
systemctl enable NetworkManager

#installs grub
pacman -S --noconfirm grub
grub-install --target=x86_64-efi --efi-directory=/boot/ --bootloader-id=Nuclearthreat
grub-mkconfig -o /boot/grub/grub.cfg

EOF
echo -e "\e[91mDont forget to set passwd\e[0m"
echo -e "additionally use \e[91mumount -R /mnt\e[0m"
