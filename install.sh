#!/bin/sh

# Partitioning
DEVICE=/dev/sda

SWAP_SIZE=2GiB

SWAP_PARTITION="${DEVICE}1"
ROOT_PARTITION="${DEVICE}2"

# Networking
HOSTNAME=lab

timedatectl set-ntp true

echo -e 'nameserver 8.8.8.8\nnameserver 8.8.4.4' > /etc/resolv.conf

sfdisk --delete $DEVICE

sfdisk --label dos $DEVICE << EOF
,$SWAP_SIZE,S
,,L
EOF

mkfs.ext4 -F $ROOT_PARTITION
mkswap $SWAP_PARTITION

mount $ROOT_PARTITION /mnt
swapon $SWAP_PARTITION

reflector --save /etc/pacman.d/mirrorlist --country Brazil

pacstrap /mnt \
  base \
  linux \
  linux-firmware \
  vim \
  grub \
  dosfstools \
  mtools \
  zsh \
  networkmanager \
  sudo \
  --noconfirm

genfstab -U /mnt >> /mnt/etc/fstab

echo 'en_US.UTF-8' >> /mnt/etc/locale.gen
echo 'LANG=en_US.UTF-8' > /mnt/etc/locale.conf
echo 'KEYMAP=us' > /mnt/etc/vconsole.conf
echo '%wheel ALL=(ALL:ALL) ALL' >> /mnt/etc/sudoers.d/10-installer
echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /mnt/etc/sudoers.d/10-installer

echo $HOSTNAME > /mnt/etc/hostname
echo -e "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t$HOSTNAME.localdomain $HOSTNAME" > /mnt/etc/hosts

cp -R -p ./ /mnt/root/archinstall
arch-chroot /mnt /root/archinstall/sys-conf.sh

umount -R /mnt
reboot
