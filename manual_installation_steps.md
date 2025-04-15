# Overview of a general manual installation inside of archiso
## Preliminary Steps
```bash
# Check UEFI bitness
cat /sys/firmware/fw_platform_size

# Connect to the internet via wifi
iwctl --passphrase passphrase station "device-name" connect "network-name"

# Synchronize system clock
timedatectl status
timedatectk list-timezones
timedatectl set-timezone "Your/Timezone"

# Partition Disk (using sfdisk for now>
sfdisk /dev/sda <<EOF
label:gpt
size="EFI size", type=U
size="SWAP size", type=S
size="ROOT size", type=L
size="HOME size", type=L
write
EOF

# Prepare filesystems
mkfs.fat -F 32 /dev/"disk"1
mkswap /dev/"disk"2
mkfs.ext4 /dev/"disk"3
mkfs.ext4 /dev/"disk"4
```

# Installation Step

```bash
# Mount partitions
mount --mkdir /dev/"disk"3 /mnt
mount --mkdir /dev/"disk"1 /mnt/boot
mount --mkdir /dev/"disk"4 /mnt/home
swapon /dev/"disk"2

# Install packages to new root
pacstrap -K /mnt base linux linux-firmware
# additional packages to consider adding:
# - sudo man
# - efibootmgr grub
# - neovim git base-devel
# - networkmanager

# Generate automatic mountpoint
genfstab -U /mnt >> /mnt/etc/fstab

# Change root to new system
arch-chroot "directory path"

# Inside new system
# Set-up timezone?
ln -sf /usr/share/zoneinfo/"Your Timezone" /etc/localtine
hwclock -- systohc

# Set-up locales
cat <<EOF > /etc/locale.get
"encoding".UTF-8 UTF-8
"encoding".UTF-8 UTF-8
EOF
locale-gen
cat <<EOF > /etc/locale.conf
LANG="encoding".UTF-8 UTF-8
EOF
cat <<EOF > /etc/vconsole.conf
KEYMAP="Your keyboard layout"
EOF

# Set-up host files
cat <<EOF > /etc/hostname
"Host Name"
EOF

cat <<EOF > /etc/hosts
127.0.0.1       localhost
::1             localhost
127.0.1.1       arch.localdomain    "Host Name"
EOF

# Set-up users
passwd
useradd -mG wheel "username"
passwd "username"
EDITOR=nvim visudo #uncomment wheel sudo line

# Set-up GRUB Bootloader
grub-insall --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Start certain packages
systemctl enable "service"
systemctl start "service"

# Exit new system
exit

# Unmount and reboot
umount -R /mnt
reboot


# Set-up configs

```

## Configure new system
```
# Install AUR's and other preffered packages
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

## Set-up configs
startx
...

```
