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
echo -e "Choose the disk/device for ${B}partitioning ${E}, like sda, sdb, etc.: "
read -r thesda
echo
echo -e "${B}Partitioning${E} with gdisk utility: "
echo
echo -e "${B}commands${E}: ${B}o${E} -new GUID partition table, ${B}n${E} -new partition, ${B}w${E} -write table to disk ${B}q${E} -quit program "
echo
echo -e "For basic ${P}Boot partitions${E}, Size: ${G}+300M${E} Hex code: ${P}ef00${E}  "
echo
gdisk /dev/"$thesda"
echo
lslblk
echo -e "${B}Formating${E} the partitions: "
echo -e "Give the ${R}root partition${E} or hit ENTER: "
read -r root 
if [ -n "$root" ];
then 
  while true; do
    read -p "Do you want to formate this partition? Y/N" yn
    case $yn in
        [Yy]* ) echo "mkfs.ext4 /dev/$root"
                mkfs.ext4 /dev/$root
                echo "${B}mount${B} ${R}/dev/$root${B} ${B}/mnt${E}"
                mount /dev/"$root" /mnt; break;;
        [Nn]* ) echo "${B}mount${B} ${R}/dev/$root${B} ${B}/mnt${E}"
                mount /dev/"$root" /mnt; break;;
        * ) echo "Please answer yes or no.";;
    esac
  done  
else echo -e "It's ${C}OK${E}"
fi
echo 
lsblk
echo
echo -e "Give the ${LB}boot/efi partition${E} or hit ENTER: "
read -r boot 
if [ -n "$boot" ];
then 
  while true; do
    read -p "Do you want to formate this partition? Y/N" yn
    case $yn in
        [Yy]* ) echo "mkfs.fat -F32 /dev/$boot"
                mkfs.fat -F32 /dev/$boot 
                echo -e "${G}Creating${E} the ${C}EFI${E} folder and ${B}Mounting${E} it: "
                echo "mkdir /mnt/efi" 
                mkdir /mnt/efi
                echo "mount /dev/$boot /mnt/efi"
                mount /dev/"$boot" /mnt/efi;break;;
        [Nn]* ) echo -e "${G}Creating${E} the ${C}EFI${E} folder and ${B}Mounting${E} it: "
                echo "mkdir /mnt/efi" 
                mkdir /mnt/efi
                echo "mount /dev/$boot /mnt/efi"
                mount /dev/"$boot" /mnt/efi;break;;
        * ) echo "Please answer yes or no.";;
    esac
  done  
else echo -e "It's ${C}OK${E}"
fi

echo
echo -e "Choose the ${C}swap partition${E}: "
read -r swap 
if [ -n "$swap" ];
then
  echo "mkswap /dev/$swap"
  mkswap /dev/$swap
  echo "swapon /dev/$swap"
  swapon /dev/"$swap"
else echo -e "It's ${G}OK${E}"
fi
echo
echo -e "The created ${LB}partition${E} table with ${LB}mounted partitions${E}:"
echo
lsblk
echo
#echo -e "Press ${G}ENTER${E} to continue..."
 while true; do
    read -p "Do you want to install the firmware? Y/N" yn
    case $yn in
        [Yy]* ) echo -e "Installing ${Y}Essential packages${E}, like ${P}base linux linux-firmware${E} and ${G}git${E} ofc"
                echo "pacstrap /mnt base linux linux-firmware"
                pacstrap /mnt base linux linux-firmware; break;;
        [Nn]* ) echo "firmware install skipped";break;;
        * ) echo "Please answer yes or no.";;
    esac
  done  


#read -r -s -p $'Press enter to go forward with the installation..'

echo
echo -e "${C}genfstab${E} -U /mnt >> /mnt/etc/fstab"
genfstab -U /mnt >> /mnt/etc/fstab
echo
echo -e "Switching from the live ${Y}iso/arch install${E} to the recently installed ${C}Arch Linux${E}"
#echo -e "Download the git package with: git clone https://github.com/ghartausz/archer.git"
echo
echo -e "${R}First part ENDED${E}"
echo
sed -n '138,$p' doer.sh > /mnt/inst.sh
chmod +x /mnt/inst.sh
echo -e "${G}Second file comitted ok${E}"
echo
read -r -s -p $"Press "${G}ENTER"${E} to go forward with the installation.."
echo
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
echo -e "${G}Second file reached ok${E}"
echo
echo -e "${Y}Time${E} ${Y}zones${E}:"
echo
ls /usr/share/zoneinfo
echo
echo -e "Type your ${Y}Time${E} ${Y}zone${E} from the above list"
read -r timezone
ls /usr/share/zoneinfo/"$timezone"
echo
echo -e "Type your ${Y}City${E} from "${C}$timezone"${G}"
read -r city
echo "ln -sf /usr/share/zoneinfo/"$timezone"/"$city" /etc/localtime"
ln -sf /usr/share/zoneinfo/"$timezone"/"$city" /etc/localtime
echo "hwclock --systohc"
hwclock --systohc
echo
read -r -s -p $"Press "${G}ENTER"${E} to go forward with the installation.."
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
echo -e "Installing some packages like ${G}networkmanager${E} ${R}nano${E} ${P}base-devel${E}..."
pacman -S --noconfirm networkmanager nano base-devel
echo
echo -e "Next step...${P}bootloader${E}"
echo
echo -e "Installing ${G}GRUB${E}"
echo
pacman -S grub efibootmgr os-prober ntfs-3g --noconfirm
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --removable 
grub-mkconfig -o /boot/grub/grub.cfg
echo
systemctl enable NetworkManager
echo
echo -e "Enter your ${G}username${E}:"
read username
useradd -m $username
usermod -aG wheel $username
echo "$username ALL=(ALL) ALL" >> /etc/sudoers.d/$username
echo
passwd $username
echo
echo -e "Adding 32bit support, uncommenting ${Y}multilib${E}:"
sed -i '/multilib]/s/^#//g' /etc/pacman.conf
sed -i '94s/#Include/Include/g' /etc/pacman.conf
echo
# use -e for displaying the changes only
echo -e "${G}Updating system${E}:"
pacman -Syu
echo
echo -e "${R}DONE, at least with the basic ones${E}"
echo
echo -e "Do you want to install the 3D stuff ${G}now${E} [press ${G}Y${E}] or ${R}later${E} [press ${R}N/n ${E}] ? "
read -p "" -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    sed -n '228,$p' inst.sh > /home/$username/3d.sh
    chmod +x /home/$username/3d.sh
    echo -e "Copied the ${G}3D stuff${E} to ${P}/~/3d.sh ${E}"  
else    
	while true; do
	    read -p "Do you want to install the 3D stuff later? Y/N" yn
	    case $yn in
		[Yy]* ) sed -n '228,$p' inst.sh > /home/$username/3d.sh
			chmod +x /home/$username/3d.sh; break;;
		[Nn]* ) read -p "Do you want to install wmware guest system tools? " -n 1 -r
								echo    # (optional) move to a new line
									if [[ $REPLY =~ ^[Yy]$ ]]
									then
								pacman -S gtkmm open-vm-tools --noconfirm
								pacman -S xf86-video-vmware xf86-input-vmmouse
								systemctl enable vmtoolsd.service 
								systemctl enable vmware-vmblock-fuse.service
									fi
									read -p "Installing GNOME DE? " -n 1 -r
									echo    # (optional) move to a new line
									if [[ $REPLY =~ ^[Yy]$ ]]
										then
												pacman -S --noconfirm xorg gdm gnome gnome-extra
												systemctl enable gdm.service
												read -p "Disable Wayland for better 3D acceleration? " -n 1 -r
												echo    # (optional) move to a new line
												if [[ $REPLY =~ ^[Yy]$ ]]
													then
													sed -i '/Wayland/s/^#//g/' /etc/gdm/custom.conf
													cat /etc/gdm/custom.conf
											fi
										fi
										read -p "Sekiro GRUB theme? " -n 1 -r
										echo    # (optional) move to a new line
										if [[ $REPLY =~ ^[Yy]$ ]]
										then
												pacman -S --noconfirm git
												git clone https://github.com/semimqmo/sekiro_grub_theme.git
												cd sekiro_grub_theme
												chmod +x install.sh
												./install.sh
										fi
										echo;break;;
		* ) echo "Please answer yes or no.";;
	    esac
	  done
fi  
echo
echo -e "${B}Unmounting everything${E}:"
echo "If not successful type 'umount -R /mnt'"
exit 
umount -R /mnt



