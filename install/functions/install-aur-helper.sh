#!/bin/bash

install_aur_helper() {
	info "Installing AUR helper (paru)..."

	if ! command -v paru &>/dev/null; then
		cd /tmp
		git clone https://aur.archlinux.org/paru.git
		cd paru
		makepkg -si --noconfirm
		cd ..
		rm -rf paru
		log "✓ paru installed successfully"
	else
		log "paru already installed"
	fi
}
