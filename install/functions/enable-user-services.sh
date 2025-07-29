#!/bin/bash

enable_user_services() {
	info "Enabling user services..."

	local services=("pipewire.service" "pipewire-pulse.service" "wireplumber.service")

	for service in "${services[@]}"; do
		if systemctl --user list-unit-files | grep -q "^$service"; then
			systemctl --user enable "$service"
			log "Enabled $service"
		else
			warn "Service $service not found"
		fi
	done

	log "User services enabled"
}
