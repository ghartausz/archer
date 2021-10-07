#!/bin/bash

C="\e[36m" #CYAN
E="\e[0m" #ENDCOLOR
G="\e[31m" #GREEN
LB="\e[1;34m" #LIGHT BLUE
B=="\e[34m" #BLUE

echo -e "Multiple setps wait ahead, choose ${C}wisely${E}:"
echo " "
echo "Checking for${C} EFI ${E} mode"
ls /sys/firmware/efi/efivars
echo " "
echo -e "${G}Network{E} interfaces: "
ip link
echo -e "Ping${G}Google{E} : "
ping -c 3 google.com
echo -e "Updating system ${LB}clock{E}: "
timedatectl set-ntp true
echo -e "${B}Identifying${E} devices and paritions: "
lsblk
echo -e "Choose the disk/device for ${B}partitioning ${E}: "
read thesda
echo -e "${B}Partitioning${E} with gdisk utility: "
gdisk /dev/thesda
printf "END"
