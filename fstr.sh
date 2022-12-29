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
read device
parted -s "$device" mklabel gpt
parted -s "$device" mkpart primary "EFI system partition" fat32 1MiB 512MiB
parted -s "$device" set 1 esp on
mkfs.fat -F32 "${device}1"
parted -s "$device" mkpart primary  "root partition" ext4 512MiB 100%
parted -s "$device" set 2 lvm on
mkfs.ext4 "${device}2"
mount "${device}2" /mnt
mount --mkdir ${device}1" /mnt/boot
echo "Server = http://mirrors.kernel.org/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
reflector --country Romania, --protocol https --latest 5 --save /etc/pacman.d/mirrorlist
sudo pacman -S archlinux-keyring
pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/Europe/Bucharest /etc/localtime"
arch-chroot /mnt /bin/bash -c "hwclock --systohc"

echo "en_US.UTF-8" >> /mnt/etc/locale.gen
arch-chroot /mnt /bin/bash -c "locale-gen"

echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "127.0.0.1 localhost" > /mnt/etc/hosts
echo "::1 localhost" >> /mnt/etc/hosts
echo "127.0.1.1 isildur.localdomain isildur" >> /mnt/etc/hosts

arch-chroot /mnt /bin/bash -c "useradd ghartausz" 
useradd ghartausz
arch-chroot /mnt /bin/bash -c  "usermod -aG wheel $username"
echo "$username ALL=(ALL) ALL" >> /mnt/etc/sudoers
echo "root password"
echo "root:$rootpassword" | chpasswd --root /mnt
echo "$username:$password" | chpasswd --root /mnt

arch-chroot /mnt /bin/bash -c "pacman -S --noconfirm networkmanager nano"
arch-chroot /mnt /bin/bash -c "pacman -S grub efibootmgr os-prober ntfs-3g --noconfirm"
arch-chroot /mnt /bin/bash -c "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --removable "
arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
arch-chroot /mnt /bin/bash -c "systemctl enable NetworkManager"
arch-chroot /mnt /bin/bash -c "umount -R /mnt"