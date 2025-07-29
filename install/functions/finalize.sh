#!/bin/bash

finalize() {
	clear
	log "bare-arch installation complete!"
	echo
	cat <<EOF
Your Arch system has been fully configured with:
- All base packages installed
- AUR packages installed via paru
- User services enabled (PipeWire, etc.)
- Dotfiles installed and configured
- Shell configured (zsh)

The installation service has been disabled and will not run again.

You can now enjoy your fully configured bare-arch system!
EOF
	echo

	# Show final notification
	if command -v notify-send &>/dev/null; then
		notify-send "bare-arch Installation" "Installation complete! Your system is ready." -i dialog-ok
	fi
}
