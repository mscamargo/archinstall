#!/bin/bash

source "./functions/logging.sh"
source "./functions/error-handling.sh"
source "./functions/check-user.sh"
source "./functions/refresh-arch-keys.sh"
source "./functions/update-arch.sh"
source "./functions/configure-swap.sh"
source "./functions/install-aur-helper.sh"
source "./functions/install-packages.sh"
source "./functions/setup-user-env.sh"
source "./functions/configure-shell.sh"
source "./functions/install-dotfiles.sh"
source "./functions/enable-user-services.sh"
source "./functions/finalize.sh"

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
