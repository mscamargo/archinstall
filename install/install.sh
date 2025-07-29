#!/bin/bash

source "$ROOT_DIR/install/functions/logging.sh"
source "$ROOT_DIR/install/functions/error-handling.sh"
source "$ROOT_DIR/install/functions/check-user.sh"
source "$ROOT_DIR/install/functions/refresh-arch-keys.sh"
source "$ROOT_DIR/install/functions/update-arch.sh"
source "$ROOT_DIR/install/functions/configure-swap.sh"
source "$ROOT_DIR/install/functions/install-aur-helper.sh"
source "$ROOT_DIR/install/functions/install-packages.sh"
source "$ROOT_DIR/install/functions/setup-user-env.sh"
source "$ROOT_DIR/install/functions/configure-shell.sh"
source "$ROOT_DIR/install/functions/install-dotfiles.sh"
source "$ROOT_DIR/install/functions/enable-user-services.sh"
source "$ROOT_DIR/install/functions/finalize.sh"

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
