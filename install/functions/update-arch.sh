update_arch() {
	info "Updating Arch Linux..."
	sudo pacman --noconfirm -Syu
	log "Arch Linux updated"
}
