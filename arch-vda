#!/bin/bash

loadkeys fr
pacman -Sy
@echo "[Instruction] Press N -> x4 Enter"
@echo "[Instruction] Press A"
@echo "[Instruction] Press W"
fdisk /dev/vda
pvcreate /dev/vda1
vgcreate vol0 /dev/vda1
lvcreate -L 400MO vol0 -n lv_swap
lvcreate -L 500MO vol0 -n lv_boot
lvcreate -L 15GO vol0 -n lv_root
lvcreate -L 5GO vol0 -n lv_home
mkfs.ext4 /dev/mapper/vol0-lv_root
mkfs.ext4 /dev/mapper/vol0-lv_home
mkfs.ext2 /dev/mapper/vol0-lv_boot
mkswap /dev/mapper/vol0-lv_swap
swapon /dev/mapper/vol0-lv_swap
mount /dev/mapper/vol0-lv_root /mnt
mount --mkdir /dev/mapper/vol0-lv_home /mnt/home
pacstrap -i /mnt base base-devel linux linux-firmware networkmanager network-manager-applet dialog iw wireless_tools iproute2 wpa_supplicant vim neovim nano sudo
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

@echo "Pass to root installe in /mnt"
@echo "Set localtime"
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc --utc
@echo "Choose a locale"
echo "en_US.UTF-8 UTF8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "KEYMAP=fr" >> /etc/vconsole.conf
echo "gamut-epitech-2025" >> /etc/hostname
echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1    localhost" >> /etc/hosts
echo "127.0.1.1    gamut.localdomain    gamut" >> /etc/hosts
@echo "Enter your new root password"
passwd
useradd -m -g users -G wheel -s /bin/bash tmpusr
@echo "Enter your new user password"
passwd tmpusr
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
pacman -S grub
grub-install /dev/vda
grub-mkconfig -o /boot/grub/grub.conf
mkinitcpio -p linux
@echo "You can now reboot your system"
