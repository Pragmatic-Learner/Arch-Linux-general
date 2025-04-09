#!/bin/bash
confirm="empty"
until [[ $confirm == "Y" ]] || [[ $confirm == "N" ]]; do	#Setting Up time
	unset Region && unset City
	clear
	echo -e "\n\n\n"
	timedatectl status
	echo -e "\n\n\n"
	echo -e "List of commands:"
	echo -e "\tY = Change timezone"
	echo -e "\tN = Do not change timezone"
	read -p "Change timezone ( Y/n )" confirm
	confirm=${confirm^^}
	if [[ $confirm == "Y" ]]; then
		clear
		echo "Entering timezones... [ Format: Region/City ]"
		echo "Note :"
		echo -e "\tFIRST LETTER of [[ Region ]] and [[ City ]] should be UPPERCASE."
		echo -e "\tREST SHOULD BE LOWERCASE"
		echo -e "Here is the available Regions And City"
		echo
		echo
		cd /usr/share/zoneinfo
		ls -Ad */
		echo
		echo "DISPLAYING REGIONS"
	
		read -p "Enter timezone [ Region ] : " Region			#	Input	Region
	
		if [ -d "/usr/share/zoneinfo/$Region" ]; then			#If folder /usr/share/zoneinfo/Region exists
			cd /usr/share/zoneinfo/$Region
			echo
			echo
			ls -A
			echo
			read -p "Enter timezone [ City ] : " City		#	Input	City
	
			if [ -f "/usr/share/zoneinfo/$Region/$City" ]; then
				timezone="${Region}/${City}"
				timedatectl set-timezone $timezone
			else
				echo "ERROR!! CITY DOES NOT EXIST"
			fi
		elif [ -f "/usr/share/zoneinfo/%Region" ]; then			#If file /usr/share/zoneinfo/Region exists
			timezone=$Region
			timedatectl set-timezone $timezone
		else
			echo "ERROR!!  REGION DOES NOT EXIST"
		fi
		timedatectl set-ntp true
		timedatectl
		read -p "Confirm timezone set-up ( Y/n ) : " confirm
		confirm=${confirm^^}
	fi
done


confirm="N"
#setting up disk partitions
while [[ $confirm != "Y" ]]; do
	disk="empty" && efi="empty" && swap="empty" && root="empty"
	until [ -d "/sys/block/$disk" ]; do
		clear
		lsblk && fdisk -l
		read -p "Enter name of disk to format : " disk
		[[ -z $disk ]] && disk="empty"
	done
	echo "Disk found, beginning formatting..."

	until [[ $lgptdos == "gpt" ]] || [[ $lgptdos == "dos" ]]; do
		clear
		echo "Disk		: /dev/$disk"
		echo
		read -p "Enter label ( gpt / dos ) :: " lgptdos
		[[ -z $lgptdos ]] && lgptdos="empty"
	done

	echo "Add one of these suffix' to the end of the partition size: K, M, G, T, P"
	
	until [[ $efi =~ ^[0-9]+(K|M|G|T|P)$ ]]; do
		clear
		echo -e "Disk\t\t: /dev/$disk"
		echo -e "Disk label\t: $lgptdos"
		echo
		read -p "Enter size of EFI boot partition (default = 512MB)	:: " efi
		[[ -z $efi ]] && efi="512M"
	done

	until [[ $swap =~ ^[0-9]+(K|M|G|T|P)$ ]] || [[ -z $swap ]]; do
		clear
		echo -e "Disk\t\t: /dev/$disk"
		echo -e "Disk label\t: $lgptdos"
		echo -e "EFI size\t: $efi"
		echo
		read -p "Enter size of SWAP partition (default = None)		:: " swap
	done

	until [[ $root =~ ^[0-9]+(K|M|G|T|P)$ ]] || [[ $root == "+" ]]; do
		clear
		echo -e "Disk\t\t: /dev/$disk"
		echo -e "Disk label\t: $lgptdos"
		echo -e "EFI size\t: $efi"
		echo -e "SWAP size\t: $swap"
		echo
		read -p "Enter size of ROOT partition (default = ALL)		:: " root
		[[ -z $root ]] && root="+"
	done
	clear
	echo -e "Disk\t\t: /dev/$disk"
	echo -e "Disk label\t: $lgptdos"
	echo -e "EFI size\t: $efi"
	echo -e "SWAP size\t: $swap"
	echo -e "ROOT size\t: $root"
	echo
	lsblk
	read -p "Confirm set-up ( Y/n ) ?" confirm
	confirm=${confirm^^}
	[[ $confirm == "N" ]] && continue

#Must add ability to choose root filesystem in the future
#List of filesystems:Ext, Ext2, Ext3, Ext4,Xiafs, JFS, BTRFS, XFS, bcachefs, ReiserFS, Resier4, SquashFS, NTFS, exFAT

#setting up partition and filesystems
	sfdisk --delete /dev/$disk
	if [[ -z $swap ]]; then
		echo -e "label:$lgptdos\n size=$efi, type=U\n size=$root, type=L" | sfdisk /dev/sda

		mkfs.ext4 /dev/"$disk"2
		mkfs.fat -F 32 /dev/"$disk"1
	
		mount /dev/"$disk"2 /mnt
		mount --mkdir /dev/"$disk"1 /mnt/boot
	else
		echo -e "label:$lgptdos\n size=$efi, type=U\n size=$swap, type=S\n size=$root, type=L" | sfdisk /dev/sda
	
		mkfs.fat -F 32 /dev/sda1				#	Setting up filesystems
		mkswap /dev/sda2
		mkfs.ext4 /dev/sda3
	
		mount /dev/sda3 /mnt					#	Mounting partitions
		mount --mkdir /dev/sda1 /mnt/boot
		swapon /dev/sda2
	fi
	unset efi && unset swap && unset root
done

#installing packages
pacstrap -K /mnt base linux linux-firmware man sudo reflector efibootmgr neovim grub
#base-devel git kitty
#grub or rEFInd or LILO or ELILO or SYSLINUX or Petitboot or (builtins systemd-boot or EFI boot stub)
#networkmanager
#ffmpeg mpv gimp
#mesa intel-ucode vulkan-intel intel-media-driver libvpl vpl-gpu-rt intel-media-sdk
#sof-firmware pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber
#virtualbox-guest-utils

#xorg-server xorg-xinit
#cutefish

genfstab -U /mnt >> /mnt/etc/fstab					#	generate automatic mount points

cat <<END > /mnt/install.sh
#!/bin/bash
disk=$disk
clear
ln -sf /usr/share/zoneinfo/$timezone /etc/localtine
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8 UTF-8" >> /etc/locale.conf
echo "KEYMAP=us" >> /etc/vconsole.conf
echo "ARCH" >> /etc/hostname
echo "123.0.0.1 localhost" >> /etc/hosts
echo "::1 localhost" >> /etc/hosts
echo "123.0.1.1 ARCH" >> /etc/hosts
clear
echo "Enter ROOT PASSWORD : "
passwd
read -p "Enter name for main Profile (THIS PROFILE WILL BE GRANTED WHEEL PRIVILEDGES, basicly admin) : " nuser
useradd -mG wheel \$nuser
echo "Enter password for main Profile \$nuser :: "
passwd \$nuser
EDITOR=nvim visudo
echo
while true; do
	read -p "ADD ANOTHER USER ( Y/n ) ? " confirm
	confirm=\${confirm^^}
	if [[ \$confirm == "Y" ]]; then
		read -p "Enter name of new user :: " nuser
		if getent passwd \$nuser > /dev/null; then
			clear
			echo "User already exist"
			continue
		else
			clear
			useradd -m \$nuser
			echo "User \$nuser created"
			echo "Enter password for user \$nuser"
			passwd \$nuser
		fi
	elif [[ \$confirm == "N" ]]; then
		echo "No additional users to be added"
		break
	else
		echo "Invalid input"
		continue
	fi
done
clear
blkid /dev/"\$disk"1
echo
#read -p "WRITE THE PARTUUID exactly as is, into the input request :: " partuuid

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
unset disk

#sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
#yay -Y --gendb
#yay -Syu --devel
#yay -Y --devel --save
#yay brave-bin

timedatectl set-ntp true
systemctl enable NetworkManager
systemctl enable vboxservice.service
systemctl start sddm.service
exit
END
unset disk

arch-chroot /mnt

read -p "Checkpoint : " check
umount -R /mnt

