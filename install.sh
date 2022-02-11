#!/bin/sh

DEVICE=/dev/sda

EFI_SIZE=1GiB
SWAP_SIZE=2GiB

EFI_PARTITION="${DEVICE}1"
SWAP_PARTITION="${DEVICE}2"
ROOT_PARTITION="${DEVICE}3"

timedatectl set-ntp true

sfdisk --delete $DEVICE

sfdisk --label gpt $DEVICE << EOF
,$EFI_SIZE,U
,$SWAP_SIZE,S
,,L
EOF

mkfs.fat -F 32 $EFI_PARTITION
mkswap $SWAP_PARTITION
mkfs.ext4 -F $ROOT_PARTITION

mount $ROOT_PARTITION /mnt
mkdir -p /mnt/boot
mount $EFI_PARTITION /mnt/boot
swapon $SWAP_PARTITION
