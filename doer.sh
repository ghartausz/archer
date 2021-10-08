#!/bin/bash

C="\e[36m" #CYAN
E="\e[0m" #ENDCOLOR
G="\e[32m" #GREEN
R="\e[31m" #RED
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
then 
  echo "mkfs.fat -F32 /dev/$boot"
  mkfs.fat -F32 /dev/$boot
else echo "tralla"
fi
echo -e "The root ${P}partition${E}: "
read -r root 
if [ -n "$root" ];
then 
  echo "mkfs.ext4 /dev/$root"
  mkfs.ext4 /dev/$root
  else echo "tralla"
fi
echo -e "The swap ${C}partition${E}: "
read -r swap 
if [ -n "$swap" ];
then
  echo "mkswap /dev/$swap"
  mkswap /dev/$swap
else echo "tralla"
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
echo
echo -e "The created ${LB}partition${E} table with mounted ${LB}partitions${E}:"
lsblk
echo
#echo -e "Press ${G}ENTER${E} to continue..."
echo -e "Installing ${Y}Essential packages${E}, like ${P}base linux linux-firmware${E} and ${G}git${E} ofc"
read -r -s -p $'Press enter to go forward with the installation..'
echo "pacstrap /mnt base linux linux-firmware"
pacstrap /mnt base linux linux-firmware
echo
echo -E "${C}genfstab${E} -U /mnt >> /mnt/etc/fstab"
genfstab -U /mnt >> /mnt/etc/fstab
echo
echo -e "Switching from  the live ${Y}iso/arch install${E} to the recently installed ${C}Arch Linux${E}"
#echo -e "Download the git package with: git clone https://github.com/ghartausz/archer.git"
echo
echo -e "${R}First part ENDED${E}"
echo
sed -n '89,$p' doer.sh > /mnt/inst.sh
chmod +x /mnt/inst.sh
read -r -s -p $"Press ENTER to go forward with the installation.."
arch-chroot /mnt ./inst.sh
exit 0

#---SECOND PART---#
C="\e[36m" #CYAN
E="\e[0m" #ENDCOLOR
G="\e[32m" #GREEN
R="\e[31m" #RED
LB="\e[1;34m" #LIGHT BLUE
B="\e[34m" #BLUE
P="\e[35m" #PURPLE
Y="\e[33m" #YELLOW
echo
echo -e "${Y}Time${E} ${Y}zones${E}:"
ls /usr/share/zoneinfo
echo -e "Type your ${Y}Time${E} ${Y}zone${E} from the above list"
read -r timezone
ls /usr/share/zoneinfo/"$timezone"
echo -e "Type your ${Y}City${E} from $timezone"
read -r city
echo "ln -sf /usr/share/zoneinfo/"$timezone"/"$city" /etc/localtime"
ln -sf /usr/share/zoneinfo/"$timezone"/"$city" /etc/localtime
echo "hwclock --systohc"
hwclock --systohc
read -r -s -p $"Press enter to go forward with the installation.."
echo 
echo -e "${B}Uncommenting${E}the en_US.UTF-8 UTF-8 line"
sed -i '19,$s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
echo 
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo
echo -e "Type in your ${R}hostname${E}:"
read -r hostname
echo "$hostname" >> /etc/hostname
echo
echo -e "Creating entrties like ${C}127.0.0..${E} to the /etc/hosts file"
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $hostname.localdomain $hostname" >> /etc/hosts
echo
echo -e "${P}Initramfs${E}"
mkinitcpio -P
echo -e "Type in your ${R}root password${E}:"
passwd
echo
echo -e "Installing some packages like ${G}networkmanager${E}..."
pacman -S networkmanager
echo
echo -e "Next step...bootloader"
echo -e "Installing ${G}GRUB${E}"
pacman -S grub efibootmgr os-prober ntfs-3g
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --removable
grub-mkconfig -o /boot/grub/grub.cfg
echo
systemctl enable NetworkManager
echo
echo -e "Enter your ${G}username${E}"
read username
useradd -m -G $username
passwd $username
echo -e "Adding 32bit support, uncommenting ${Y}multilib${E}:"
sed -i '/multilib]/s/^#//g' /etc/pacman.conf
sed -i '94s/#Include/Include/g' /etc/locale.gen 
# use -e for displaying the changes only
echo -e "${G}Updating system${E}:"
pacman -Syu


