#!/bin/sh

cd $HOME
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg --noconfirm -si
yay -S --noconfirm brave-bin
