setup_error_handling() {
	set -e
	trap 'error "Script failed at line $LINENO"' ERR
}
