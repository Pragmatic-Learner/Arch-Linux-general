#!/bin/bash
#Setting Up time
confirm="empty"
until [[ $confirm == "Y" ]] || [[ $confirm == "N" ]] || [[ -z $confirm ]];#Decide whether to change timezone or not
	clear
	echo -e "\n\n\n"
	timedatectl status
	echo -e "\n\n\n"
	echo -e "List of commands:"
	echo -e "\tY = Change timezone"
	echo -e "\tN = Do not change timezone"
	read -p "Change timezone? [ default = N ] " confirm
	confirm=${confirm^^}
done



unset confirm 
while true; do								#Keep Asking for Region And City input until proper matches are found
	clear && echo "Entering timezones... [ Format: Region/City ]"
	echo "Note :"
	echo -e "\tFIRST LETTER of [[ Region ]] and [[ City ]] should be UPPERCASE."
	echo -e "\tREST SHOULD BE LOWERCASE"
	echo -e "Here is the available Regions And City\n\n\n"
	cd /usr/share/zoneinfo && ls -Ad */
	echo -e "\n\n\nDISPLAYING REGIONS"
	


	read -p "Enter timezone [ Region ] : " Region			#Region Input



	if [ -d "/usr/share/zoneinfo/$Region" ]; then
		cd /usr/share/zoneinfo/$Region && ls -Ad */
		read -p "Enter timezone [ City ] : " City		#City Input

		if [ -f "/usr/share/zoneinfo/$Region/$City" ]; then
			timedatectl set-timezone $Region/$City
			break						#break
		else
			echo "ERROR!! CITY DOES NOT EXIST"
		fi
	elif [ -f "/usr/share/zoneinfo/%Region" ]; then
		timedatectl set-timezone $Region
		break							#break
	else
		echo "ERROR!!  REGION DOES NOT EXIST"
	fi
	unset Region && unset City
done
unset Region && unset City
timedatectl set-ntp true




#setting up disk partitions
disk="notadrive"


until [ -d "/sys/block/$disk" ]; do clear && lsblk && fdisk -l; read -p "Enter name of disk to format : " disk; done

echo "Disk found, beginning formatting..."

until [[ $lgptdos == "gpt" ]] || [[ $lgptdos == "dos" ]]; do read -p "Enter label ( gpt / dos ) :: " lgptdos; done

echo "Add one of these suffix' to the end of the partition size: K, M, G, T, P"

until [[ $efi =~ ^[0-9]+(K|M|G|T|P)$ ]] || [[ -z $efi ]]; do read -p "Enter size of EFI boot partition (default = 512MiB)	:: " efi; done
until [[ $swap =~ ^[0-9]+(K|M|G|T|P)$ ]] || [[ -z $swap ]]; do read -p "Enter size of SWAP partition (default = None)		:: " swap; done
until [[ $root =~ ^[0-9]+(K|M|G|T|P)$ ]] || [[ -z $root ]]; do read -p "Enter size of ROOT partition (default = ALL)		:: " root; done
#Must add ability to choose root filesystem in the future

#setting up partition and filesystems
[[ -z $efi ]] && efi="512MiB"
[[ -z $root ]] && root="+"

if [[ -z $swap ]]; then
	echo -e "label:$lgptdos\n size=$efi, type=U\n size=$root, type=L" | sfdisk /dev/sda
	
	mkfs.fat -F 32 /dev/sda1						#Setting up filesystems
	mkfs.ext4 /dev/sda2

	mount /dev/sda2 /mnt							#Mounting partitions
	mount --mkdir /dev/sda1 /mnt/boot
else
	echo -e "label:$lgptdos\n size=$efi, type=U\n size=$swap, type=S\n size=$root, type=L" | sfdisk /dev/sda

	mkfs.fat -F 32 /dev/sda1						#Setting up filesystems
	mkswap /dev/sda2
	mkfs.ext4 /dev/sda3

	mount /dev/sda3 /mnt							#Mounting partitions
	mount --mkdir /dev/sda1 /mnt/boot
	swapon /dev/sda2
fi
unset efi && unset swap && unset root

#installing packages			replace intel-ucode with amd-ucode if using amd cpu alright
pacstrap -K /mnt base linux linux-firmware efibootmgr ffmpeg sudo reflector base-devel man git neovim networkmanager
#pacstrap -K /mnt base linux linux-firmware base-devel intel-ucode git neovim efibootmgr grub networkmanager mesa xf86-video-intel vulkan-intel  libva-mesa-driver mesa-vdpau sof-firmware pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber kitty reflector openssh man sudo gimp
#virtualbox-guest-utils
#pcmanfm ffmpeg mpv
#cutefish just to see how it looks

genfstab -U /mnt >> /mnt/etc/fstab						#generate automatic mount points

cat <<END > /mnt/install.sh
#!/bin/bash
disk=$disk
ln -sf /usr/share/zoneinfo/Time/Zone /etc/localtine
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

echo "Enter ROOT PASSWORD : "
passwd
read -p "Enter name for main Profile (THIS PROFILE WILL BE GRANTED WHEEL PRIVILEDGES, basicly admin) : " wUser
useradd -mG wheel \$wuser
echo "Enter password for main Profile :: "
passwd
while true; do
	read -p "ADD ANOTHER USER ( Y/n ) ? " confirm && confirm=\${confirm^^}
	if [[ \$confirm == "Y" ]]; then
		read -p "Enter name of new user :: " nuser
		if getent passwd \$nuser > /dev/null; then
			echo "User already exist"
			sleep 0.7
		else
			useradd -mG wheel \$nuser
			echp -e "User \$nuser created\nEnter password for user \$nuser"
			passwd \$nuser
			clear
		fi
	elif [[ \$confirm == "N" ]]; then
		echo "No more users to be added"
		break
	else
		clear && echo "Invalid input"
	fi
done
blkid /dev/"$disk"1
echo ""
read -p "WRITE THE PARTUUID exactly as is, into the input request :: " partuuid
efibootmgr --create --disk /dev/$disk --part 1 --label "Arch Linux" --loader /vmlinuz-linux --unicode "root=PARTUUID=$partuuid rw initrd=\initramfs-linux.img"
exit
END
unset disk && clear
echo "sh install.sh" | arch-chroot /mnt

read -p "Checkpoint : " check
umount -R /mnt
timedatectl set-ntp true
systemctl enable NetworkManager
systemctl enable vboxservice.service
#systemctl start sddm.service
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

yay -Y --gendb
yay -Syu --devel
yay -Y --devel --save
yay brave-bin
