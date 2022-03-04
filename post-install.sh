#!/bin/sh

cd $HOME
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg --noconfirm -si

yay -S xorg xorg-xinit wget tmux brave-bin zsh-completions

# Remove bash stuff
cd ~/
rm .bash*
