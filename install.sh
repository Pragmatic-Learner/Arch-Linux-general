#!/bin/bash
#setting up time
timedatectl set-ntp true

clear
lsblk
echo "Add one of these suffix' to the end of the partition size: MiB, GiB, MB, GB"
read -p "Enter size of EFI boot partition (default=512MiB)	:: " efip
read -p "Enter size of SWAP partition (default=4GiB)		:: " swapp
read -p "Enter size of ROOT partition (default=ALL)		:: " rootp
#setting up partition and filesystems
if [[ $(efip) == "" ]]; then
	efip="512MiB"
fi
if [[ $(swapp) == "" ]]; then
	swapp="4GiB"
fi
echo -e "g\nn\n\n\n$(efip)\nn\n\n\n$(swapp)\nn\n\n\n$(rootp)\nt\n1\n1\nt\n2\n19\nw\n" | fdisk /dev/sda
mkfs.fat -F 32 /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3

#mounting partitions
mount /dev/sda3 /mnt
mount --mkdir /dev/sda1 /mnt/boot
swapon /dev/sda2

#echo "include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf

#installing packages
#replace intel-ucode with amd-ucode if using amd cpy alright
pacstrap -K /mnt base base-devel linux linux-firmware intel-ucode git neovim efibootmgr networkmanager mesa xf86-video-intel vulkan-intel  libva-mesa-driver mesa-vdpau sof-firmware pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber kitty reflector openssh man sudo gimp virtualbox-guest-utils cutefish pcmanfm ffmpeg mpv
#grub

#generate automatic mount points
genfstab -U /mnt >> /mnt/etc/fstab

echo "ln -sf /usr/share/zoneinfo/Time/Zone /etc/localtine" >> /mnt/install.sh
echo "hwclock --systohc" >> /mnt/install.sh
echo "echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen" >> /mnt/install.sh
echo "echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen" >> /mnt/install.sh
echo "locale-gen" >> /mnt/install.sh
echo "echo "LANG=en_GB.UTF-8 UTF-8" >> /etc/locale.conf" >> /mnt/install.sh
echo "echo "KEYMAP=us" >> /etc/vconsole.conf" >> /mnt/install.sh
echo "echo "ARCH" >> /etc/hostname" >> /mnt/install.sh
echo "echo "123.0.0.1 localhost" >> /etc/hosts" >> /mnt/install.sh
echo "echo "::1 localhost" >> /etc/hosts" >> /mnt/install.sh
echo "echo "123.0.1.1 ARCH" >> /etc/hosts" >> /mnt/install.sh
echo "passwd" >> /mnt/install.sh
echo "useradd -mG wheel user1" >> /mnt/install.sh
echo "passwd" >> /mnt/install.sh
echo "efibootmgr --create --disk /dev/sda --part 1 --label "Arch Linux" --loader /vmlinuz-linux --unicode 'root=block_device_identifier rw initrd=\initramfs-linux.img'" >> install.sh
echo "exit" >> /mnt/install.sh

arch-chroot /mnt

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
