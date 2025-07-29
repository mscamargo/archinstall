#!/bin/bash

install_base_packages() {
	info "Installing base packages..."

	local PACKAGES_FILE="./packages.csv"

	[[ ! -f "$PACKAGES_FILE" ]] && error "Packages file $PACKAGES_FILE not found"

	local installed_count=0
	local failed_count=0

	# Read and install packages one at a time
	while IFS=, read -r tag prog desc; do
		# Skip empty lines, comments, and AUR packages (handle separately)
		[[ -z "$prog" || "$prog" =~ ^[[:space:]]*# || "$tag" == "A" ]] && continue

		# Skip git repos for now (handle them separately)
		[[ "$tag" == "G" ]] && continue

		# Clean up program name (remove any extra whitespace)
		prog=$(echo "$prog" | xargs)

		info "Installing $prog..."
		if sudo pacman --noconfirm -S "$prog"; then
			log "✓ $prog installed successfully"
			installed_count=$((installed_count + 1))
		else
			warn "✗ Failed to install $prog"
			failed_count=$((failed_count + 1))
		fi
	done <"$PACKAGES_FILE"

	log "Base packages installation complete: $installed_count installed, $failed_count failed"
}
