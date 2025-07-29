#!/bin/bash

setup_user_env() {
	info "Setting up user environment..."

	local DOTFILES_REPO="https://github.com/mscamargo/dotfiles"
	local src_dir="$HOME/.local/src"

	# Create directories
	mkdir -p "$src_dir"

	# Clone dotfiles
	if [[ ! -d "$src_dir/dotfiles" ]]; then
		info "Cloning dotfiles..."
		git clone "$DOTFILES_REPO" "$src_dir/dotfiles"
		log "Dotfiles cloned"
	fi

	log "User environment set up"
}
