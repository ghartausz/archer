#!/bin/bash

C="\e[36m" #CYAN
E="\e[0m" #ENDCOLOR
G="\e[32m" #GREEN
LB="\e[1;34m" #LIGHT BLUE
B="\e[34m" #BLUE
P="\e[35m" #PURPLE
Y="\e[33m" #YELLOW
b="\e[1m" #bold

echo
echo "genfstab -U /mnt >> /mnt/etc/fstab"
genfstab -U /mnt >> /mnt/etc/fstab
echo
echo -e "Switching fromt the live ${Y}iso/arch install${E} to the recently installed ${C}Arch Linux${E}"
echo "arch-chroot /mnt"
arch-chroot /mnt
echo
echo -e "${Y}Time zones${E}:"
ls /usr/share/zoneinfo
echo "Type your ${Y}Time zone${E} from the above list"
read timezone
ls /usr/share/zoneinfo/$timezone
echo "Type your ${Y}City${E} from the list"
read city
echo "ln -sf /usr/share/zoneinfo/$timezone/$city /etc/localtime"
ln -sf /usr/share/zoneinfo/$timezone/$city /etc/localtime
echo "hwclock --systohc"
hwclock --systohc
echo "Uncommenting the en_US.UTF-8 UTF-8 line"
sed -i '19,$s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
echo "Generating locale"
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo -e "Type in your ${R}hostname${E}:"
read -r hostname
echo "$hostname" >> /etc/hostname
echo -e "Creating entrties like ${C}127.0.0..${E} to the /etc/hosts file"
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $hostname.localdomain $hostname" >> /etc/hosts
echo
echo -e "${P}Initramfs${E}"
mkinitcpio -P
echo -e "Type in your ${R}root password${R}:"
passwd

