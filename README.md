# Arch Linux General set up
This repo is to save my general set up for arch Linux, to facillitate re-installing linux.  It should set up arch and also sets of graphic design and utility packages.

# General Processes (in order)
- [ ] Check UEFI bitness
    1. cat /sys/firmware/efi/fw\_platform\_size
- [ ] Set-Up Time
    1. timedatectl
    2. timedatectl set-timezone "Time/Zone"
    3. timedatectl set-ntp True
- [ ] Set-Up network
    1. iwctl
    2. iwctl device list
    3. iwctl station "device-name" scan
    4. iwctl --passphrase passphrase station "device-name" connect "network-name"
- [ ] Partition disk
    1. lsblk
    2. fdisk -l
    3. fdisk /dev/"disk-name"
    4. {g, n, \<default\>, \<default\>, "EFI-size", n, \<default\>, \<default\>, "SWAP-size", n, \<default\>, \<default\>, "ROOT-size", w}
- [ ] Set up filesystems
    1. mkfs.fat -F 32 /dev/"disk-name"1
    2. mkswap /dev/"disk-name"2
    3. mkfs.ext4 /dev/"disk-name"3
- [ ] Mount disk(partition)
    1. mount /dev/"disk-name"3 /mnt
    3. mount --mkdir /dev/"disk-name"1 /mnt/boot
    3. swapon /dev/"disk-name"2

## List of graphic design packages
1. Blender3D
2. Krita
3. Inkscape
4. pinta

## List of utility packages
1. Git
2. Neovim
3. MPV
4. FFMPEG
5. Obsidian

Hopefully I keep learning bash and zsh for continuing this.

If anyone stumbles upon this in the future, when it's better shaped, I hope you find it usefull or interesting.

