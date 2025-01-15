#!/bin/bash

# Configuration du clavier français
loadkeys fr

# Mise à jour des miroirs
pacman -Sy

# Partitionnement du disque
echo "Création de la partition pour LVM..."
# Créer une partition unique de type Linux LVM (8e)
(
echo n    # Nouvelle partition
echo p    # Partition primaire
echo 1    # Numéro de partition
echo      # Premier secteur (défaut)
echo      # Dernier secteur (défaut - utilise tout l'espace)
echo e    # Redimensionne la partition
echo 21G  # Défini la taille de la partition a 21G
echo t    # Changer le type
echo 8e   # Type Linux LVM
echo w    # Écrire les changements
) | fdisk /dev/sda

# Configuration LVM
pvcreate /dev/sda1
vgcreate vol0 /dev/sda1

# Création des volumes logiques
# Notez: MO = MB, GO = GB
lvcreate -L 400M vol0 -n lv_swap
lvcreate -L 500M vol0 -n lv_boot
lvcreate -L 15G vol0 -n lv_root
lvcreate -L 5G vol0 -n lv_home

# Formatage des partitions
mkfs.ext4 /dev/vol0/lv_root
mkfs.ext4 /dev/vol0/lv_home
mkfs.ext2 /dev/vol0/lv_boot    # ext2 pour /boot est suffisant
mkswap /dev/vol0/lv_swap
swapon /dev/vol0/lv_swap

# Montage des systèmes de fichiers
mount /dev/vol0/lv_root /mnt
mkdir /mnt/boot
mount /dev/vol0/lv_boot /mnt/boot
mkdir /mnt/home
mount /dev/vol0/lv_home /mnt/home

# Installation du système de base
pacstrap /mnt base base-devel linux linux-firmware lvm2 networkmanager \
    network-manager-applet dialog wpa_supplicant wireless_tools \
    iw iproute2 vim neovim nano sudo

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

# Installation et configuration de GRUB
pacman -S --noconfirm grub
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

echo "Création du mot de passe root..."
echo "Veuillez définir le mot de passe root :"
passwd

# Création de l'utilisateur
useradd -m -g users -G wheel -s /bin/bash tmpusr
echo "Veuillez définir le mot de passe pour tmpusr :"
passwd tmpusr

# Configuration de sudo
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

# Activation des services
systemctl enable NetworkManager
echo "Use script install from tictacgame repo" >> /dev/installscript
EOF

echo "Installation terminée. Vous pouvez maintenant redémarrer le système."
