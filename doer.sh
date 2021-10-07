#!/bin/bash

C="\e[36m" #CYAN
E="\e[0m" #ENDCOLOR
G="\e[32m" #GREEN
LB="\e[1;34m" #LIGHT BLUE
B="\e[34m" #BLUE
P="\e[35m" #PURPLE
Y="\e[33m" #YELLOW


echo -e "Multiple setps wait ahead, choose ${C}wisely${E}:"
echo " "
echo -e "Checking for${C} EFI ${E} mode:"
ls /sys/firmware/efi/efivars
echo " "
echo -e "${G}Network${E} interfaces: "
ip link
echo
echo -e "${G}PingGoogle${E} : "
ping -c 3 google.com
echo
echo -e "Updating system ${LB}clock${E}: "
echo "timedatectl set-ntp true"
timedatectl set-ntp true
echo
echo -e "${B}Identifying${E} devices and paritions: "
lsblk
echo
echo -e "Choose the disk/device for ${B}partitioning ${E}: "
read -r thesda
echo -e "${B}Partitioning${E} with gdisk utility: "
echo -e "${B}commands${E}: ${B}o${E} -new GUID partition table, ${B}n${E} -new partition, ${B}w${E} -write table to disk ${B}q${E} -quit program "
echo
gdisk /dev/"$thesda"
echo
echo -e "${B}Formating${E} the partitions: "
echo -e "Give the boot/efi ${LB}partition${E} or hit ENTER: "
read -r boot 
if [ -n "$boot" ];
  then echo "mkfs.fat -F32 /dev/$boot"
  else echo "tralala"
fi
echo -e "The root ${P}partition${E}: "
read -r root 
if [ -n "$root" ];
  then echo "mkfs.ext4 /dev/$root"    
fi
echo -e "The swap ${C}partition${E}: "
read -r swap 
if [ -n "$swap" ];
  then  echo "mkswap /dev/$swap"
fi
echo
echo -e "${B}Mounting${E} the partitions: "
echo "mount /dev/$root /mnt"
mount /dev/"$root" /mnt
echo -e "${G}Creating${E} the ${C}EFI${E} folder and ${B}Mounting${E} it: "
echo "mkdir /mnt/efi" 
mkdir /mnt/efi
echo "mount /dev/$boot /mnt/efi"
mount /dev/"$boot" /mnt/efi
echo "swapon /dev/$swap"
swapon /dev/"$swap"
echo -e "The created ${LB}partition${E} table with mounted ${LB}partitions${E}:"
lsblk
echo
#echo -e "Press ${G}ENTER${E} to continue..."
echo -e "Installing ${Y}Essential packages${E}, like ${P}base linux linux-firmware${E} and ${G}git${E} ofc"
read -r -s -p $'Press enter to go forward with the installation..'
echo "pacstrap /mnt base linux linux-firmware"
pacstrap /mnt base linux linux-firmware
echo
echo "genfstab -U /mnt >> /mnt/etc/fstab"
genfstab -U /mnt >> /mnt/etc/fstab
echo
echo -e "Switching fromt the live ${Y}iso/arch install${E} to the recently installed ${C}Arch Linux${E}"
#echo -e "Download the git package with: git clone https://github.com/ghartausz/archer.git"
echo
echo "${R}First part ENDED${E}"
echo
read -r -s -p $"Press enter to go forward with the installation.."
cd ..
cp -R archer /mnt
arch-chroot /mnt /archer/inst.sh
