refresh_arch_keys() {
	info "Refreshing Arch Linux keyrings..."
	sudo pacman --noconfirm -S archlinux-keyring
	log "Keyrings refreshed"
}
