#setting up some variables
confirm="empty"

#setting up time
until [[ $confirm == "Y" ]] || [[ $confirm == "N" ]] || [[ -z $confirm ]]; do #Decide whether or not to change time
	clear && timedatectl status
	echo -e "List of commands:\n\tY = Change timezone\n\tN = Do not change timezone"
	read -p "Change timezone? [ default = Y ] " confirm && confirm=${confirm^^}
	timezone="invalid"
done
while true; do #Change time until time is confirmed
	Region="" && City=""

	#Prompt
	echo "Entering timezones... [ Format: Region/City ]"
	echo "Note :"
	echo -e "\tFIRST LETTER of [[ Region ]] and [[ City ]] should be UPPERCASE."
	echo -e "\tREST SHOULD BE LOWERCASE"
	echo "Here is the available Regions And City"
	cd /usr/share/zoneinfo && ls && echo "DISPLAYING REGIONS"

	#Input
	read -p "Enter timezone [ Region ] : " Region
	if [ -d "/usr/share/zoneinfo/$Region" ]; then
		cd /usr/share/zoneinfo/$Region && ls
		read -p "Enter timezone [ City ] : " City
		if [ -f "/usr/share/zoneinfo/$Region/$City" ]; then
			timedatectl set-timezone $Region/$City
		else
			echo "ERROR!! CITY DOES NOT EXIST"
			continue
		fi
	elif [ -f "/usr/share/zoneinfo/%Region" ]; then
		timedatectl set-timezone $Region
	else
		echo "ERROR!!  REGION DOES NOT EXIST"
		continue
	fi
	break
done
timedatectl set-ntp true

#setting up disk partitions
clear && lsblk && fdisk -l
echo "Add one of these suffix' to the end of the partition size: K, M, G, T, P"
read -p "Enter size of EFI boot partition (default = 512MiB)	:: " efi
read -p "Enter size of SWAP partition (default = None)		:: " swap
read -p "Enter size of ROOT partition (default = ALL)		:: " root
#setting up partition and filesystems
if [[ -z $efi ]]; then
	efi="512MiB"
fi
if [[ -z $root ]]; then
	root="+"
fi
if [[ -z $swap ]]; then
	echo -e "label:gpt\n size=$efi, type=U\n size=$root, type=L" | sfdisk /dev/sda
else
	echo -e "label:gpt\n size=$efi, type=U\n size=$swap, type=S\n size=$root, type=L" | sfdisk /dev/sda
fi

#echo -e "g\nn\n\n\n$(efi)\nn\n\n\n$(swap)\nn\n\n\n$(root)\nt\n1\n1\nt\n2\n19\nw\n" | fdisk /dev/sda

#setting up filesystem
mkfs.fat -F 32 /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3

#mounting partitions
mount /dev/sda3 /mnt
mount --mkdir /dev/sda1 /mnt/boot
swapon /dev/sda2

#installing packages
#replace intel-ucode with amd-ucode if using amd cpu alright
pacstrap -K /mnt base linux linux-firmware base-devel intel-ucode git neovim efibootmgr grub networkmanager mesa xf86-video-intel vulkan-intel  libva-mesa-driver mesa-vdpau sof-firmware pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber kitty reflector openssh man sudo gimp virtualbox-guest-utils cutefish pcmanfm ffmpeg mpv

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

echo "install.sh" | arch-chroot /mnt

umount -R /mnt
timedatectl set-ntp true
#systemctl enable NetworkManager
#systemctl enable vboxservice.service
#systemctl start sddm.service
#sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

#yay -Y --gendb
#yay -Syu --devel
#yay -Y --devel --save
#yay brave-bin
