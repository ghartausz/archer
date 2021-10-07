#!/bin/bash

C="\e[36m" #CYAN
E="\e[0m" #ENDCOLOR
G="\e[32m" #GREEN
LB="\e[1;34m" #LIGHT BLUE
B=="\e[34m" #BLUE
P=="\e[35m" #PURPLE

echo -e "Multiple setps wait ahead, choose ${C}wisely${E}:"
echo " "
echo -e "Checking for${C} EFI ${E} mode"
ls /sys/firmware/efi/efivars
echo " "
echo -e "${G}Network${E} interfaces: "
ip link
echo -e "Ping${G}Google${E} : "
ping -c 3 google.com
echo -e "Updating system ${LB}clock${E}: "
timedatectl set-ntp true
echo -e "${B}Identifying${E} devices and paritions: "
lsblk
echo -e "Choose the disk/device for ${B}partitioning ${E}: "
read thesda
echo -e "${B}Partitioning${E} with gdisk utility: "
echo -e "${B}commands${E}: ${B}o${E} -new GUID partition table, ${B}n${E} -new partition, ${B}w${E} -write table to disk " 
gdisk /dev/$thesda
echo -e "${B}Formating${E} the partitions: "
echo -e "Give the boot/efi ${LB}partition${E} or hit ENTER: "
read boot 
if [ -n $boot];
  then echo "mkfs.fat -F32 /dev/$boot"
fi
echo -e "The root ${P}partition${E}: "
read root 
if [ -n $root];
  then echo "mkfs.ext4 /dev/$root"    
fi
echo -e "The swap ${C}partition${E}: "
read swap 
if [ -n $swap];
  then  echo "mkswap /dev/$swap"
fi

printf "END"
