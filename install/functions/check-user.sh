check_user() {
	USERNAME=$(whoami)

	if [[ $EUID -eq 0 ]]; then
		error "This script should be run as a regular user, not as root"
	fi

	info "Running as user: $USERNAME"
}
