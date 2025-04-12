#!/bin/bash
three_dots() {
	echo -n $1
	sleep 1
	echo -n "."
	sleep 1
	echo -n "."
	sleep 1
	echo "."
	clear
	return 0
}

clear
choice_Update_system_clock="empty"
#timedatectl status
while [[ ${choice_Update_system_clock} != "Y" && ${choice_Update_system_clock} != "N" ]]; do
	read -p "Change timezone ( Y/n ) : " choice_Update_system_clock
	choice_Update_system_clock=${choice_Update_system_clock^^}

	if [[ ${choice_Update_system_clock} == "Y" ]]; then
		three_dots "Proceeding to change system clock, please choice you Region and City"

	elif [[ ${choice_Update_system_cloc} == "N" ]]; then
		three_dots "No changes made.  Proceeding to disk partitioning"

	else
		three_dots "Invalid Input"
	fi
done

while [[ ${choice_Update_system_clock} == "Y" ]]; do
	confirm_Timezone_change="empty"
	Timezone="empty"
	Region="empty"
	City="empty"
	echo "Format: Region/City  || Respect the Capitalizations"
	echo "DISPLAYING REGIONS"
	cd /usr/share/zoneinfo
	ls -A
	echo

	read -p "Enter Region : " Region; : "${Region:=empty}"

	if [[ -f "/usr/share/zoneinfo/${Region}" ]]; then #	I wonder if  /usr/share/zoneinfo/. or /usr/share/zoneinfo/~ can be valid paths
		Timezone="$Region"
	elif [[ -d "/usr/share/zoneinfo/${Region}" ]]; then
		echo "DISPLAYING CITIES"
		cd /usr/share/zoneinfo/${Region}
		ls -A
		echo

		read -p "Enter City : " City; : "${City:=empty}"

		if [[ -f "/usr/share/zoneinfo/${Region}/${City}" ]]; then
			Timezone="${Region}/${City}"
		else
			three_dots "City does not exist"
			continue
		fi
	else
		three_dots "Region does not exist"
		continue
	fi

	while [[ ${confirm_Timezone_change} != "Y" && ${confirm_Timezone_change} != "N" ]]; do
		clear
		timedatectl set-timezone ${Timezone}
		read -p "Confirm Timezone ( Y/n ) : " cofirm_Timezone_change
		cofirm_Timezone_change=${cofirm_Timezone_change^^}

		if [[ ${confirm_Timezone_change} == "Y" ]]; then
			three_dots "Changes confirmed, Proceeding to disk partitioning"

		elif [[ ${confirm_Timezone_change} == "N" ]]; then
			three_dots "Changes rejected by user, starting input again"
			timedatectl set-timezone UTC

		else
			three_dots "Invalid input"
		fi
	done
	unset confirm_Timezone_change
	unset Region
	unset City
done
timedatectl set-ntp true
unset choice_Update_system_clock

Disk_Partition_SetUp() {
	clear
	echo -e "Disk name\t\t: ${Disk_Name}"
	echo -e "Disk path\t\t: /dev/${Disk_Name:-unset}"
	echo -e "Partitioning scheme\t: ${Partitioning_scheme:-unset}"
	echo
	echo -e "EFI  size\t\t: ${EFI_Size:-unset}"
	echo -e "SWAP size\t\t: ${SWAP_Size:-unset}"
	echo -e "ROOT size\t\t: ${ROOT_Size:-unset}"
}

confirm_Disk_Partitions="empty"
while [[ ${confirm_Disk_Partitions} != "Y" ]]; do
	Disk_Name="unset"
	while [[ ! -d "sys/block/${Disk_Name}" ]]; do
		Disk_Partition_SetUp
		clear
		lsblk
		echo
		fdisk -l
		read -p "Enter name of disk to partition : " Disk_Name; : "${Disk_Name:=unset}"
	done
	three_dots "Disk found, beginning formatting"

	while [[ ${Partitioning_Scheme} != "gpt" && ${Partitioning_Scheme} != "dos" ]]; do
		Disk_Partition_SetUp
		read -p "Enter partitioning scheme ( gpt/dos ) : " Partitioning_Scheme
		[[ $Partitioning_Scheme != "gpt" || $Partitioning_Scheme != "dos" ]] && three_dots "Invalid Input"
	done


	echo "Add one of these suffix' to the end of the partition size: K, M, G, T, P"

	while [[ ! ${Size_Input} =~ ^[0-9]+(K|M|G|T|P)$ } ]]; do
		Disk_Partitioning_SetUp
		read -p "Enter size of EFI boot partition ( default = 512M ) : " Size_Input; : "${Size_Input=512M}"
	done
	EFI_Size=${Size_input}
	while [[ ! ${Size_Input} =~ ^[0-9]+(K|M|G|T|P)$ ]]; do
		Disk_Partitioning_SetUp
		read -p "Enter size of SWAP partition ( default = None ) : " Size_Input; : "${Size_Input=No Swap}"
	done
	SWAP_Size=${Size_Input}
	while [[ ! ${Size_Input} =~ ^[0-9]+(K|M|G|T|P)$ && -n ${Size_Input} ]]; do
		Disk_Partition_SetUp
		read -p "Enter size of ROOT partition ( default = ALL ) : " Size_Input; : "${Size_Input=ALL}"
	done
	ROOT_Size=${Size_Input}

	while [[ ${confirm_Disk_Partitions} != "Y" && ${confirm_Disk_Partitions} != "N" ]]; do
		Disk_Partition_Scheme
		echo
		read -p "Confirm the choosen settings for pertitioning the disk ( Y/n ) : " confirm_Disk_Partitions
		confirm_Disk_Partitions=${confirm_Disk_Partitions^^}
	done
	
done

sfdisk --delete /dev/${Disk_Name}
[[ ${ROOT_Size} == "ALL" ]] && ROOT_Size="+"
if [[ ${SWAP_Size} == "No Swap" ]]; then
	echo -e "label:${Partitioning_Scheme}\n size=${EFI_Size}, type=U\n size=${ROOT_Size}, type=L" | sfdisk /dev/sda

	mkfs.ext4 /dev/"$disk"2
	mkfs.fat -F 32 /dev/"$disk"1

	mount /dev/"$disk"2 /mnt
	mount --mkdir /dev/"$disk"1 /mnt/boot
else
	echo -e "label:${Partitioning_Scheme}\n size=${EFI_Swap}, type=U\n size=${SWAP_Size}, type=S\n size=${ROOT_Size}, type=L" | sfdisk /dev/sda

	mkfs.fat -F 32 /dev/${Disk_Name}1
	mkswap /dev/${Disk_Name}2
	mkfs.ext4 /dev/${Disk_Name}3

	mount /dev/${Disk_Name}3 /mnt
	mount --mkdir /dev/${Disk_Name}1 /mnt/boot
	swapon /dev/${Disk_Name}2
fi
unset confirm_Disk_Partitions
unset Disk_Name
unset Size_Input
unset Partitioning_scheme
unset EFI_Size
unset SWAP_Size
unset ROOT_Size

clear
#installing packages
pacstrap -K /mnt base linux linux-firmware man sudo reflector efibootmgr gub neovim base-devel git kitty networkmanager ffmpeg mpv mesa intel-ucode vulkan-intel intel-media-driver libvpl vpl-gpu-rt intel-media-sdk sof-firmware pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber

#xorg xorg-init
#virtualbox-guest-utils

#sddm "cutefish"
#grub or rEFInd or LILO or ELILO or SYSLINUX or Petitboot or (builtins systemd-boot or EFI boot stub)

genfstab -U /mnt >> /mnt/etc/fstab					#	generate automatic mount points

cat <<END > /mnt/install.sh
#!/bin/bash
clear
ln -sf /usr/share/zoneinfo/$Timezone /etc/localtine
hwclock --systohc
echo -e "en_US.UTF-8 UTF-8\nen_GB.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8 UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "ARCH" > /etc/hostname
echo -e "123.0.0.1 localhost\n::1 localhost\n123.0.1.1 ARCH" > /etc/hosts
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
echo

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

#sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
#yay -Y --gendb
#yay -Syu --devel
#yay -Y --devel --save
#yay brave-bin

timedatectl set-ntp true
systemctl enable NetworkManager
systemctl enable vboxservice.service
systemctl start sddm.service
systemctl enable sddm.service
END

unset Timezone

arch-chroot /mnt

umount -R /mnt

