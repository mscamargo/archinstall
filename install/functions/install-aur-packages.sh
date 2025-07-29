#!/bin/bash

install_aur_packages() {
	info "Installing AUR packages..."

	local PACKAGES_FILE="./packages.csv"

	[[ ! -f "$PACKAGES_FILE" ]] && error "Packages file $PACKAGES_FILE not found"

	local installed_count=0
	local failed_count=0

	# Read and install AUR packages
	while IFS=, read -r tag prog desc; do
		# Skip non-AUR packages
		[[ "$tag" != "A" ]] && continue
		[[ -z "$prog" || "$prog" =~ ^[[:space:]]*# ]] && continue

		# Clean up program name
		prog=$(echo "$prog" | xargs)

		info "Installing $prog from AUR..."
		if paru -S --noconfirm "$prog"; then
			log "✓ $prog installed successfully"
			installed_count=$((installed_count + 1))
		else
			warn "✗ Failed to install $prog"
			failed_count=$((failed_count + 1))
		fi
	done <"$PACKAGES_FILE"

	log "AUR packages installation complete: $installed_count installed, $failed_count failed"
}
