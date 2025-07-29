#!/bin/bash

configure_swap() {
	info "Checking swap configuration..."

	local swapfile="/swapfile"

	# Check if swapfile exists and is configured
	if [[ -f "$swapfile" ]]; then
		log "Swapfile already exists"
	else
		warn "No swapfile found. Creating 8GB swapfile..."
		sudo fallocate -l 8G "$swapfile" || sudo dd if=/dev/zero of="$swapfile" bs=1G count=8
		sudo chmod 600 "$swapfile"
		sudo mkswap "$swapfile"

		# Add to fstab if not already there
		if ! grep -q "$swapfile" /etc/fstab; then
			echo "$swapfile none swap defaults 0 0" | sudo tee -a /etc/fstab
		fi
	fi

	# Enable swap if not already enabled
	if ! swapon --show | grep -q "$swapfile"; then
		sudo swapon "$swapfile"
	fi

	# Configure swappiness if not already set
	if ! grep -q "vm.swappiness=100" /etc/sysctl.conf; then
		echo "vm.swappiness=100" | sudo tee -a /etc/sysctl.conf
		echo "vm.vfs_cache_pressure=100" | sudo tee -a /etc/sysctl.conf
		sudo sysctl vm.swappiness=100
		sudo sysctl vm.vfs_cache_pressure=100
	fi

	log "Swap configuration complete"
}
