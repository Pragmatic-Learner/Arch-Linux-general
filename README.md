# Arch Linux General set up
This repo is to save my general set up for arch Linux, to facillitate re-installing linux.  It should set up arch and also sets of graphic design and utility packages.

# Processes (in order)
- [ ] Set-Up Time
    - timedatectl
    - timedatectl set-timezone "Time/Zone"
    - timedatectl set-ntp True
2. Set-Up network
    - iwctl
    - device list
    - station "device-name" scan
    - station "device-name" connect "network-name"
    - Enter passphrase
3. Partition disk
    - lsblk
    - fdisk -l
    - fdisk /dev/"disk-name"
    - {g, n, <default>, <default>, "EFI-size", n, <default>, <default>, "SWAP-size", n, <default>, <default>, "ROOT-size", w}
4. Set up filesystems
    - mkfs.fat -F 32 /dev/"disk-name"1
    - mkswap /dev/"disk-name"2
    - mkfs.ext4 /dev/"disk-name"3
5. Mount disk(partition)
    - mount /dev/"disk-name"3 /mnt
    - mount --mkdir /dev/"disk-name"1 /mnt/boot
    - swapon /dev/"disk-name"2

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

