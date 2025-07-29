#!/bin/bash

configure_shell() {
	info "Configuring user shell..."

	# Check if zsh is installed
	if ! command -v zsh &>/dev/null; then
		warn "zsh not found, skipping shell configuration"
		return
	fi

	# Set zsh as default shell for the user
	if chsh -s /bin/zsh; then
		log "✓ Set zsh as default shell"
	else
		warn "Failed to set zsh as default shell"
	fi
}
