#!/bin/sh

ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc

locale-gen

# Root password
echo 'Set root password'
passwd

grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager

pacman --noconfirm -S zsh

echo 'Set your user:'
read USERNAME
useradd -m -s /bin/zsh $USERNAME
usermod -aG wheel $USERNAME
passwd $USERNAME
