#!/bin/sh

iwctl --passphrase 05170212 station wlan0 connect Interneta

read -p "Device: " DEVICE
read -p "Swap Size: " SWAP_SIZE

SWAP_PARTITION="${DEVICE}1"
ROOT_PARTITION="${DEVICE}2"

timedatectl set-ntp true

cp ./etc/resolv.conf /etc/resolve.conf

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
  neovim \
  grub \
  dosfstools \
  mtools \
  zsh \
  networkmanager \
  iwd \
  sudo \
  git \
  base-devel \
  curl \
  ca-certificates \
  reflector \
  --noconfirm

genfstab -U /mnt >> /mnt/etc/fstab
cp -R ./etc/* /mnt/etc
cp -R -p ./ /mnt/root/archinstall
arch-chroot /mnt /root/archinstall/sys-conf.sh

# umount -R /mnt
# reboot
