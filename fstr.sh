#!/bin/bash

set -e

# Ensure script is run as root
if [ "$EUID" -ne 0 ]
then
    echo "Please run as root"
    exit
fi

ls /sys/firmware/efi/efivars
ip link
ping -c 3 google.com
timedatectl set-ntp true
lsblk
echo
echo "Enter the device you want to install to (e.g. /dev/sda):"
read device
parted -s "$device" mklabel gpt
parted -s "$device" mkpart "EFI system partition" fat32 1MiB 512MiB
parted -s "$device" set 1 esp on
mkfs.fat -F32 "${device}1"
parted -s "$device" mkpart "root partition" ext4 512MiB 100%
parted -s "$device" set 2 lvm on
mkfs.ext4 "${device}2"
mount "${device}2" /mnt
mount --mkdir ${device}1" /mnt/boot
mkdir /mnt/efi
mount "${device}1" /mnt/boot
echo "Server = http://mirrors.kernel.org/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
reflector --country Romania, --protocol https --latest 5 --save /etc/pacman.d/mirrorlist
sudo pacman -S archlinux-keyring
pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/Europe/Bucharest /etc/localtime"
arch-chroot /mnt /bin/bash -c "hwclock --systohc"

en_US.UTF-8 >> /mnt/etc/locale.gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

echo "$locale UTF-8" >> /mnt/etc/locale.gen
arch-chroot /mnt /bin/bash -c "locale-gen"
