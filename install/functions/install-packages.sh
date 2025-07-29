#!/bin/bash

install_packages() {
	info "Installing packages..."

	local PACKAGES_FILE="./packages.csv"

	[[ ! -f "$PACKAGES_FILE" ]] && error "Packages file $PACKAGES_FILE not found"

	local base_installed_count=0
	local base_failed_count=0
	local aur_installed_count=0
	local aur_failed_count=0

	# Read and install packages one at a time
	while IFS=, read -r tag prog desc; do
		# Skip empty lines and comments
		[[ -z "$prog" || "$prog" =~ ^[[:space:]]*# ]] && continue

		# Skip git repos for now (handle them separately)
		[[ "$tag" == "G" ]] && continue

		# Clean up program name (remove any extra whitespace)
		prog=$(echo "$prog" | xargs)

		# Install based on tag type
		if [[ "$tag" == "A" ]]; then
			# AUR package
			info "Installing $prog from AUR..."
			if paru -S --noconfirm "$prog"; then
				log "✓ $prog (AUR) installed successfully"
				aur_installed_count=$((aur_installed_count + 1))
			else
				warn "✗ Failed to install $prog (AUR)"
				aur_failed_count=$((aur_failed_count + 1))
			fi
		else
			# Base package (empty tag or any other tag)
			info "Installing $prog..."
			if sudo pacman --noconfirm -S "$prog"; then
				log "✓ $prog installed successfully"
				base_installed_count=$((base_installed_count + 1))
			else
				warn "✗ Failed to install $prog"
				base_failed_count=$((base_failed_count + 1))
			fi
		fi
	done <"$PACKAGES_FILE"

	log "Package installation complete:"
	log "  Base packages: $base_installed_count installed, $base_failed_count failed"
	log "  AUR packages: $aur_installed_count installed, $aur_failed_count failed"
} 