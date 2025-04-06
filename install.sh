#!/bin/bash
#setting up time
timedatectl set-ntp true

#setting up partition and filesystems
echo -e "g\nn\n\n\n+512MiB\nn\n\n\n+4G\nn\n\n\n\nt\n1\n1\nt\n2\n19\nw\n" | fdisk /dev/sda
mkfs.fat -F 32 /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3

#mounting partitions
mount /dev/sda3 /mnt
mount --mkdir /dev/sda1 /mnt/boot
swapon /dev/sda2

echo "include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
cd ~

#installing packages
#replace intel-ucode with amd-ucode if using amd cpy alright
pacstrap -K /mnt base base-devel linux linux-firmware intel-ucode git neovim efibootmgr networkmanager mesa lib32-mesa xf86-video-intel vulkan-intel lib32-vulkan-intel libva-mesa-driver mesa-vdpau sof-firmware pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber kitty reflector openssh man sudo gimp virtualbox-guest-utils cutefish pcmanfm ffmpeg mpv
#generate automatic mount points
genfstab -U /mnt >> mnt/etc/fstab

cd /mnt
echo "ln -sf /usr/share/zoneinfo/Time/Zone /etc/localtine" >> /mnt/install.sh
echo "hwclock --systohc" >> /mnt/install.sh
echo "nvim /etc/locale.gen > "en_US.UTF-8 UTF-8"" >> /mnt/install.sh
echo "nvim /etc/locale.gen >> "en_GB.UTF-8 UTF-8"" >> /mnt/install.sh
echo "locale-gen" >> /mnt/install.sh
echo "/etc/locale.conf > "LANG=en_GB.UTF-8 UTF-8"" >> /mnt/install.sh
echo "nvim /etc/vconsole > "KEYMAP=us"" >> /mnt/install.sh
echo "nvim /etc/hostname > "ARCH"" >> /mnt/install.sh
echo "nvim /etc/hosts > "123.0.0.1 localhost"" >> /mnt/install.sh
echo "nvim /etc/hosts > "::1 localhost"" >> /mnt/install.sh
echo "nvim /etc/hosts > "123.0.1.1 ARCH"" >> /mnt/install.sh
echo "passwd" >> /mnt/install.sh
echo "useradd -mG wheel user1" >> /mnt/install.sh
echo "passwd" >> /mnt/install.sh
echo "efibootmgr --create --disk /dev/sdX --part Y --label "Arch Linux" --loader /vmlinuz-linux --unicode 'root=block_device_identifier rw initrd=\initramfs-linux.img'" >> install.sh

cd ~
arch-chroot /mnt
exit
umount -R /mnt
timedatectl set-ntp true
systemctl enable NetworkManager
systemctl enable vboxservice.service
systemctl start sddm.service
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

#yay -Y --gendb
#yay -Syu --devel
#yay -Y --devel --save
#yay brave-bin
