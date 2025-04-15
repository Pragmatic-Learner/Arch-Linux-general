<h1>Arch Linux General set up.  A little intro</h1>
<p>This repo is to save my general set up for arch Linux, to facillitate re-installing linux.  It should set up arch and also sets of graphic design and utility packages.</p>



<br>



<h1>General Processes (in order)</h1>

<p>
<ol>
    <h2><li>Check if UEFI boots to 32 bits or 64 bits</li></h2>
    <p>cat /sys/firmware/efi/fw\_platform\_size</p>
<br>
    <h2><li>Set-up System Clock</li></h2>
    <p>
        timedatectl
        <br>
        timedatectl set-timezone "Time/Zone"
        <br>
        timedatectl set-ntp True</p>
<br>
    <h2><li>
        </input><label for="">Set-Up Internet Connection</label>
    </li></h2>
    <pre>iwctl
iwctl device list
iwctl station "device-name" scan
iwctl --passphrase passphrase station "device-name" connect "network-name"
    </pre>
<br>
    <h2><li>
        </input><label for="">Set-Up disk partition</label>
    </li></h2>
    <pre>lsblk
fdisk -l
fdisk /dev/"disk-name"
{g, n, \<default\>, \<default\>, "EFI-size", n, \<default\>, \<default\>, "SWAP-size", n, \<default\>, \<default\>, "ROOT-size", w}</pre>
<br>
    <h2><li>
        </input><label for="">Set-Up partitions' filesystem</label>
    </li></h2>
    <pre>mkfs.fat -F 32 /dev/"disk-name"1
mkswap /dev/"disk-name"2
mkfs.ext4 /dev/"disk-name"3
    </pre>
<br>
    <h2><li>
        </input><label for="">Mount partitions</label>
    </li></h2>
    <pre>mount /dev/"disk-name"3 /mnt
mount --mkdir /dev/"disk-name"1 /mnt/boot
swapon /dev/"disk-name"2
    </pre>
<br>
    <h2><li>
        </input><label for="">Install packages</label>
    </li></h2>
    <pre>pacstrap -K base linux linux-firmware</pre>
<br>
    <h2><li>
        </input><label for="">Generate mountpoints for automatic mounting</label>
    </li></h2>
    <pre>genfstab -U /mnt >> /mnt/etc/fstab</pre>
<br>
    <h2><li>
        </input><label for="">Change root into new system</label>
    </li></h2>
    <pre>arch-chroot /mnt</pre>
<br>
    <h2><li>
        </input><label for="">Set-Up Time Zone</label>
    </li></h2>
    <pre>ln -sf /usr/share/zoneinfo/Time/Zone /etc/localtine
hwclock -- systohc</pre>
<br>
    <h2><li>
        </input><label for="">Set-Up locales</label>
    </li></h2>
    <pre>nvim /etc/locale.gen
    en_US.UTF-8 UTF-8
    en_GB.UTF-8 UTF-8
locale-gen
nvim /etc/locale.conf
    LANG=en\_GB.UTF-8 UTF-8
nvim /etc/vconsole
    KEYMAP=us</pre>
<br>
    <h2><li>
        </input><label for="">Set-Up host files</label>
    </li></h2>
    <pre>nvim /etc/hostname
    "Computer\_Name"
nvim /etc/hosts
    123.0.0.1 localhost
    ::1 localhost
    123.0.1.1 "Computer\_Name"</pre>
<br>
    <h2><li>
        </input><label for="">Set-Up Users</label>
    </li></h2>
    <pre>passwd
    "ROOT PASSWORD"
useradd -mG wheel "USERNAME"
passwd "USERNAME"
EDITOR=nvim visudo
    Uncomment line to allow whell users use sudo</pre>
<br>
    <h2><li>
        </input><label for="">Set-Up BOOTLOADER</label>
    </li></h2>
    <pre>grub-install --target=x86\_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg</pre>
<br>
    <h2><li>
        </input><label for="">Unmount and reboot</label>
    </li></h2>
    <pre>exit
umount -R /mnt
reboot
timedatectl set-ntp true
    </pre>
</ol>
</p>


<p>
<h2>List of graphic design packages</h2>
<ol>
    <li>Blender3D</li>
    <li>Krita</li>
    <li>Inkscape</li>
    <li>pinta</li>
</ol>
</p>
<p>
<h2>List of utility packages</h2>
<ol>
    <li>Git</li>
    <li>Neovim</li>
    <li>MPV</li>
    <li>FFMPEG</li>
    <li>Obsidian</li>
</ol>
Hopefully I keep learning bash and zsh for continuing this.
<br>
If anyone stumbles upon this in the future, when it's better shaped, I hope you find it usefull or interesting.
</p>
