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
read thesda
echo -e "${B}Partitioning${E} with gdisk utility: "
echo -e "${B}commands${E}: ${B}o${E} -new GUID partition table, ${B}n${E} -new partition, ${B}w${E} -write table to disk "
echo
gdisk /dev/$thesda
echo
echo -e "${B}Formating${E} the partitions: "
echo -e "Give the boot/efi ${LB}partition${E} or hit ENTER: "
read boot 
if [ -n "$boot" ];
  then echo "mkfs.fat -F32 /dev/$boot"
  else echo "tralala"
fi
echo -e "The root ${P}partition${E}: "
read root 
if [ -n "$root" ];
  then echo "mkfs.ext4 /dev/$root"    
fi
echo -e "The swap ${C}partition${E}: "
read swap 
if [ -n "$swap" ];
  then  echo "mkswap /dev/$swap"
fi
echo
echo -e "${B}Mounting${E} the partitions: "
echo "mount /dev/$root /mnt"
mount /dev/$root /mnt
echo -e "${G}Creating${E} the ${C}EFI${E} folder and ${B}Mounting${E} it: "
echo "mkdir /mnt/efi" 
mkdir /mnt/efi
echo "mount /dev/$boot /mnt/efi"
mount /dev/$boot /mnt/efi
echo "swapon /dev/$swap"
swapon /dev/$swap
echo -e "The created ${LB}partition${E} table with mounted ${LB}partitions${E}:"
lsblk
echo
#echo -e "Press ${G}ENTER${E} to continue..."
echo -e "Installing ${Y}Essential packages${E}, like ${P}base linux linux-firmware${E}"
read -r -s -p $'Press enter to go forward with the installation..'
echo "pacstrap /mnt base linux linux-firmware"
pacstrap /mnt base linux linux-firmware
echo

printf "${R}First part ENDED${E}"
read -r -s -p $'Press enter to go forward with the installation..'
sh ./inst.sh

