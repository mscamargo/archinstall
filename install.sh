#!/bin/sh

iwctl --passphrase xxxxxxx station wlan0 connect Any

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

install_pkg() {
	case $2 in
		0) 
			pacstrap /mnt $1
			;;
		1)
			git clone --depth 1 https://aur.archlinux.org/$2.git /tmp/$2
			cd /tmp/$1
			makepkg --noconfirm -si
			;;
		2)
			yay -S --noconfirm $1
			;;
		3)
			src=$HOME/.local/src
			mkdir -p $src
			pkg="$(basename "$1" .git)"
			target=$src/$pkg
			git clone $1 $target
			;;
		*) 
			pacman -S --noconfirm $1
			;;
			
	esac
}

pacstrap /mnt \
  base \
  linux \
  linux-firmware \
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
  ntp \
  --noconfirm

genfstab -U /mnt >> /mnt/etc/fstab
cp -R ./etc/* /mnt/etc
cp -R -p ./ /mnt/root/archinstall
arch-chroot /mnt /root/archinstall/sys-conf.sh

# umount -R /mnt
# reboot
