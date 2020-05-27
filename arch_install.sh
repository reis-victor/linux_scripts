#! /bin/bash

echo "README: Create the partitions in the disks before executing the script. The script will FORMAT all the necessary partitions." 
echo
read -p 'Do you really want to execute the script? Enter YES to proceed: ' START
echo
grep -q YES <<< $START || exit

# Saves important partitions and username to variables
read -p 'Input the root partition (/dev/sdxx): ' ROOT &&
echo
read -p 'Input the efi partition (/dev/sdxx): ' EFI &&
echo
read -p 'Input the swap partition (/dev/sdxx): ' SWAP &&
echo
read -p 'Input the user name: ' USER &&

# Loads us-acentos keyboard,ensures system clock accuracy
loadkeys us-acentos &&
timedatectl set-ntp true &&

# Formats ROOT partition to f2fs, formats EFI partition to FAT32 and mounts them. Also, sets the SWAP partition
mkfs.f2fs -f $ROOT && mount $ROOT /mnt && mkfs.vfat -F 32 $EFI && mkswap $SWAP && swapon $SWAP &&

# Installs current Linux kernel and firmware, Arch base and base gnome minimal setup, f2fs filesystem driver, manuals, Intel drivers, and extra apps
pacstrap /mnt base base-devel linux linux-firmware networkmanager intel-ucode vim f2fs-tools gufw zsh git firefox chromium man-db man-pages accountsservice gdm gnome-color-manager gnome-control-center gnome-desktop xorg-xrandr xorg-server xorg-server-common xorg-xinit xorg-drivers gnome-keyring gnome-session gnome-shell gnome-terminal gnome-menus gnome-tweaks nautilus eog sushi gnome-system-monitor intel-media-driver mesa mpv youtube-dl &&

# Copies fstab content to /mnt/etc/fstab file
genfstab -U /mnt >> /mnt/etc/fstab &&

# Writes script to be executed within chroot
cat <<EOF > /mnt/home/post_install.sh
#! /bin/bash

# Copies EFI and USER variables from the current environment
EFI=$EFI
USER=$USER

# Creates efi directory and mounts its partition 
mkdir /efi &&
mount $EFI /efi &&

# "yy" is used to be sure that the mirrorlist is updated and "u" upgrades the packages.Then, grub and efibootmgr are installed
pacman -Syyu &&
pacman -S grub efibootmgr &&

# Sets the zoneinfo, runs hwclock, creates locale file, and sets keyboard layout
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime &&
hwclock --systohc &&
sed -zi "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen &&
locale-gen  &&
echo "KEYMAP=us-acentos" >> /etc/vconsole.conf &&

# Creates hostname "laptop" and  adds it to the hosts file
echo "laptop" > /etc/hostname &&
echo "127.0.0.1	localhost
::1		localhost
127.0.1.1	laptop.localdomain	laptop" >> /etc/hosts &&

# Installs grub in the efi partition and updates it
grub-install --target=x86_64-efi --efi-directory=efi --bootloader-id=GRUB &&
grub-mkconfig -o /boot/grub/grub.cfg &&

# Enables NetworkManager and gdm
systemctl enable NetworkManager.service &&
systemctl enable gdm.service &&

# Unlocks all permissions to the wheel group
sed -zi "s/#%wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g" &&

# Asks for the root password
echo "Input the root password"
passwd &&

# Adds the user to the system, asks its password and adds it to the wheel group
useradd -m $USER &&
echo "Input the user password"
passwd $USER &&
gpasswd -a $USER wheel &&
EOF

# Gives execute permission to the post_install.sh script
chmod +x /mnt/home/post_install.sh &&

# Chroots to the Arch Linux install and executes the script
arch-chroot /mnt ./home/post_install.sh
