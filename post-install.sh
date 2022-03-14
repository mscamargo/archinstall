#!/bin/sh

# Sync system time
# ntpdate 0.us.pool.ntp.org

# cd $HOME
# git clone https://aur.archlinux.org/yay.git
# cd yay
# makepkg --noconfirm -si

# Install packages
while IFS=, read -r pkg step; do
	dialog --title "Installation" --infobox "Installing \`$pkg\` " 5 70
	yay -S --noconfirm $pkg >/dev/null 2>&1
done < ./packages.csv

# Remove bash stuff
# cd ~/
# rm .bash*
