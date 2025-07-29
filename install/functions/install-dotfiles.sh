expand_path() {
	echo "${1/\$HOME/$HOME}"
}

create_symlink() {
	local source="$1"
	local target="$2"
	local description="$3"

	source=$(expand_path "$source")
	target=$(expand_path "$target")

	if [[ "$source" != /* ]]; then
		source="$(pwd)/$source"
	fi

	mkdir -p "$(dirname "$target")"

	[ -e "$target" ] && rm -rf "$target"

	ln -sf "$source" "$target"
	echo "✓ $description"
}

install_dotfiles() {
	info "Installing dotfiles..."

	local CSV_FILE="./sym-links.csv"

	# Install dotfiles from CSV
	while IFS=',' read -r source_path target_path description; do
		# Skip empty lines and comments
		[[ -z "$source_path" || "$source_path" =~ ^#.*$ ]] && continue

		# Trim whitespace
		source_path=$(echo "$source_path" | xargs)
		target_path=$(echo "$target_path" | xargs)
		description=$(echo "$description" | xargs)

		# Skip if source doesn't exist
		full_source_path="./$source_path"
		[ ! -e "$full_source_path" ] && continue

		create_symlink "$source_path" "$target_path" "$description"

	done <"$CSV_FILE"

	log "Dotfiles installation complete"
}
