#!/bin/bash

set -e

# Ensure script is run as root
if [ "$EUID" -ne 0 ]
then
    echo "Please run as root"
    exit
fi

# Set the system clock to use NTP to synchronize the time
timedatectl set-ntp true

# Prompt user for installation details
echo "Enter the device you want to install to (e.g. /dev/sda):"
read device

echo "Enter the hostname you want for your machine:"
read hostname

echo "Enter your desired username:"
read username

echo "Enter your desired password:"
read -s password

echo "Enter your desired root password:"
read -s rootpassword

echo "Enter your desired locale (e.g. en_US.UTF-8):"
read locale

echo "Enter your desired time zone (e.g. America/New_York):"
read timezone

# Partition the device using GPT and create a single partition for the root filesystem
parted -s "$device" mklabel gpt
parted -s "$device" mkpart primary ext4 1MiB 100%
parted -s "$device" set 1 boot on

# Format the root partition as ext4
mkfs.ext4 "${device}1"

# Mount the root partition to /mnt
mount "${device}1" /mnt

# Set the mirrorlist to use the kernel.org mirrors
echo "Server = http://mirrors.kernel.org/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist

# Install the base system to the root partition
pacstrap /mnt base

# Generate fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Set the timezone
arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/$timezone /etc/localtime"

# Sync hardware clock with system clock
arch-chroot /mnt /bin/bash -c "hwclock --systohc"

# Generate locales
echo "$locale UTF-8" >> /mnt/etc/locale.gen
arch-chroot /mnt /bin/bash -c "locale-gen"

# Set the system locale
echo "LANG=$locale" > /mnt/etc/locale.conf

# Set the hostname
echo "$hostname" > /mnt/etc/hostname

# Set the hosts file
echo "127.0.0.1 localhost" > /mnt/etc/hosts
echo "::1 localhost" >> /mnt/etc/hosts
echo "127.0.1.1 $hostname.localdomain $hostname" >> /mnt/etc/hosts

# Add the specified user to the sudoers file
echo "$username ALL=(ALL) ALL" >> /mnt/etc/sudoers

# Set the root password
echo "root:$rootpassword" | chpasswd --root /mnt

# Set the user password
echo "$username:$password" | chpasswd --root /mnt

