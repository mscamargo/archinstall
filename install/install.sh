#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/functions/logging.sh"
source "$SCRIPT_DIR/functions/error-handling.sh"
source "$SCRIPT_DIR/functions/check-user.sh"
source "$SCRIPT_DIR/functions/refresh-arch-keys.sh"
source "$SCRIPT_DIR/functions/update-arch.sh"
source "$SCRIPT_DIR/functions/configure-swap.sh"
source "$SCRIPT_DIR/functions/install-aur-helper.sh"
source "$SCRIPT_DIR/functions/install-packages.sh"
source "$SCRIPT_DIR/functions/setup-user-env.sh"
source "$SCRIPT_DIR/functions/configure-shell.sh"
source "$SCRIPT_DIR/functions/install-dotfiles.sh"
source "$SCRIPT_DIR/functions/enable-user-services.sh"
source "$SCRIPT_DIR/functions/finalize.sh"

setup_error_handling

main() {
	check_user
	refresh_arch_keys
	update_arch
	configure_swap
	install_aur_helper
	install_packages
	setup_user_env
	configure_shell
	install_dotfiles
	enable_user_services
	finalize
}

main "$@"
