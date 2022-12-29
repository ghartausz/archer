#!/bin/bash

set -e

# Ensure script is run as root
if [ "$EUID" -ne 0 ]
then
    echo "Please run as root"
    exit
fi

timedatectl set-ntp true
timezone="Europe/Bucharest"
ls /sys/firmware/efi/efivars
ip link
ping -c 3 google.com
lsblk
echo
echo "Enter the device you want to install to (e.g. /dev/sda):"
#read device
device="/dev/sda"
parted -s "$device" mklabel gpt
parted -s "$device" mkpart "EFI_system_partition" fat32 1MiB 512MiB
parted -s "$device" set 1 esp on
mkfs.fat -F32 "${device}1"
parted -s "$device" mkpart "root_partition" ext4 512MiB 100%
parted -s "$device" set 2 lvm on
mkfs.ext4 "${device}2"
mount "${device}2" /mnt
mount --mkdir "${device}1" /mnt/boot
echo "Server = http://mirrors.kernel.org/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
reflector --country Romania, --protocol https --latest 5 --save /etc/pacman.d/mirrorlist
sudo pacman -S archlinux-keyring
pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Europe/Bucharest /etc/localtime
hwclock --systohc

#echo "en_US.UTF-8" >> /etc/locale.gen
sed -i '19,$s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "isildur" >> /etc/hostname
echo "127.0.0.1 localhost" > /etc/hosts
echo "::1 localhost" >> /etc/hosts
echo "127.0.1.1 isildur.localdomain isildur" >> /etc/hosts
mkinitcpio -P
passwd
pacman -S --noconfirm networkmanager nano
useradd ghartausz
usermod -aG wheel ghartausz
echo "ghartausz ALL=(ALL) ALL" >> /etc/sudoers


pacman -S --noconfirm base-devel networkmanager nano
pacman -S grub efibootmgr os-prober ntfs-3g --noconfirm
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --removable
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable NetworkManager
useradd ghartausz
usermod -aG wheel ghartausz
echo "ghartausz ALL=(ALL) ALL" >> /etc/sudoers
passwd ghartausz
exit
umount -R /mnt