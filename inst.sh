#!/bin/bash

C="\e[36m" #CYAN
E="\e[0m" #ENDCOLOR
G="\e[32m" #GREEN
LB="\e[1;34m" #LIGHT BLUE
B="\e[34m" #BLUE
P="\e[35m" #PURPLE
Y="\e[33m" #YELLOW

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
