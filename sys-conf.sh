#!/bin/sh

ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc

locale-gen

# Root password
echo 'Set root password'
passwd

# Grub Install
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Enable some services
systemctl enable NetworkManager
systemctl enable iwd
systemctl enable systemd-networkd
systemctl enable systemd-resolved

# Personal user
echo 'Set your user:'
read USERNAME
useradd -m -s /bin/zsh $USERNAME
usermod -aG wheel $USERNAME
passwd $USERNAME

