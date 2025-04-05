#!/bin/bash
timedatectl set-ntp true
echo -e "g\nn\n\n\n+512\nn\n\n\n+14G\nn\n\n\n\nt\n1\n1\nt\n2\n19\nw\n" | fdisk /dev/sda

mkfs.fat -F 32 /dev/sda1
mkfs.ext4 /dev/sda3
mkswap /dev/sda2

mount /dev/sda3 /mnt
mount --mkdir /dev/sda1 /mnt/boot
swapon /dev/sda2

pacstrap -K /mnt base linux linux-firmware

-U /mnt >> mnt/etc/fstab

arch-chroot

ln -sf /usr/share/zoneinfo/Time/Zone /etc/localtine
hwclock -- systohc

nvim /etc/locale.gen > "en_US.UTF-8 UTF-8"
nvim /etc/locale.gen >> "en_GB.UTF-8 UTF-8"
locale-gen
nvim /etc/locale.conf > "LANG=en\_GB.UTF-8 UTF-8"
nvim /etc/vconsole > "KEYMAP=us"

nvim /etc/hostname > "ARCH"
nvim /etc/hosts > "123.0.0.1 localhost"
nvim /etc/hosts > "::1 localhost"
nvim /etc/hosts > "123.0.1.1 ARCH"

passwd "1234"

useradd -mG wheel "user1"
passwd "1234"

grub-install --target=x86\_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

exit
umount -R /mnt
reboot
timedatectl set-ntp true
