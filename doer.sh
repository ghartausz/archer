#!/bin/bash

C="\e[36m" #CYAN
E="\e[0m" #ENDCOLOR

echo -e "Multiple setps wait ahead, choose ${C}wisely${E}:"
echo " "
echo "Looking for the ${C} EFI mode${E}"
ls /sys/firmware/efi/efivars
printf "END"
