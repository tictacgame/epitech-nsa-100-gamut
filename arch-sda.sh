#!/bin/bash

# Configuration du clavier français
loadkeys fr

# Mise à jour des miroirs
pacman -Sy

# Partitionnement du disque
echo "Création des partitions EFI et LVM..."
(
echo g    # Créer une nouvelle table de partition GPT
echo n    # Nouvelle partition
echo 1    # Numéro de partition
echo      # Premier secteur (défaut)
echo +512M # Taille de la partition EFI
echo t    # Changer le type
echo 1    # Type EFI System
echo n    # Nouvelle partition
echo 2    # Numéro de partition
echo      # Premier secteur (défaut)
echo      # Dernier secteur (défaut)
echo t    # Changer le type
echo 2    # Sélectionner la deuxième partition
echo 30   # Type LVM
echo w    # Écrire les changements
) | fdisk /dev/sda

# Formatage de la partition EFI
mkfs.fat -F32 /dev/sda1

# Configuration LVM
pvcreate /dev/sda2
vgcreate vol0 /dev/sda2

# Création des volumes logiques
lvcreate -L 400M vol0 -n lv_swap
lvcreate -L 500M vol0 -n lv_boot
lvcreate -L 15G vol0 -n lv_root
lvcreate -L 5G vol0 -n lv_home

# Formatage des partitions
mkfs.ext4 /dev/vol0/lv_root
mkfs.ext4 /dev/vol0/lv_home
mkfs.ext4 /dev/vol0/lv_boot    # ext4 pour boot en UEFI
mkswap /dev/vol0/lv_swap
swapon /dev/vol0/lv_swap

# Montage des systèmes de fichiers
mount /dev/vol0/lv_root /mnt
mkdir -p /mnt/{boot,home,boot/efi}
mount /dev/vol0/lv_boot /mnt/boot
mount /dev/sda1 /mnt/boot/efi
mount /dev/vol0/lv_home /mnt/home

# Installation du système de base
pacstrap /mnt base base-devel linux linux-firmware lvm2 networkmanager \
    network-manager-applet dialog wpa_supplicant wireless_tools \
    iw iproute2 vim neovim nano sudo efibootmgr

# Génération du fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Préparation du chroot
echo "Configuration système dans chroot..."
arch-chroot /mnt << EOF

# Configuration du fuseau horaire
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc --utc

# Configuration des locales
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=fr" > /etc/vconsole.conf

# Configuration du hostname
echo "gamut-epitech-2025" > /etc/hostname
cat > /etc/hosts << HOSTS
127.0.0.1    localhost
::1          localhost
127.0.1.1    gamut.localdomain    gamut
HOSTS

# Configuration de mkinitcpio pour LVM
sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf block lvm2 filesystems keyboard fsck)/' /etc/mkinitcpio.conf
mkinitcpio -P

# Installation et configuration de GRUB pour UEFI
pacman -S --noconfirm grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

echo "Création du mot de passe root..."
echo "Veuillez définir le mot de passe root :"
(
echo ok
echo ok
) | passwd

# Création de l'utilisateur
useradd -m -g users -G wheel -s /bin/bash tmpusr
echo "Veuillez définir le mot de passe pour tmpusr :"
(
echo ok
echo ok
) | passwd tmpusr

# Configuration de sudo
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

# Activation des services
systemctl enable NetworkManager
echo "Use script install from tictacgame repo (sda option)" >> /dev/installscript
EOF

echo "Installation terminée. Vous pouvez maintenant redémarrer le système."
