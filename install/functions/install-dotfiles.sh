#!/bin/bash

install_dotfiles() {
	info "Installing dotfiles..."

	local dotfiles_dir="$HOME/.local/src/dotfiles"
	local prev_dir=$(pwd)

	if [[ ! -d "$dotfiles_dir" ]]; then
		warn "Dotfiles not found, skipping..."
		return
	fi

	# Run install script
	if [[ -f "$dotfiles_dir/install.sh" ]]; then
		chmod +x "$dotfiles_dir/install.sh"
		cd "$dotfiles_dir"
		./install.sh
		cd "$prev_dir"
		log "Dotfiles installed"
	else
		warn "No install.sh found in dotfiles repository"
	fi

	log "Dotfiles installation complete"
}
