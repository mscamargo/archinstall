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
		source="$ROOT_DIR/$source"
	fi

	mkdir -p "$(dirname "$target")"

	[ -e "$target" ] && rm -rf "$target"

	ln -sf "$source" "$target"
	echo "✓ $description"
}

install_dotfile_recursive() {
	local source_dir="$1"
	local target_base="$2"
	
	# Find all files in the source directory
	while IFS= read -r -d '' file; do
		# Get relative path from source directory
		local relative_path="${file#$source_dir/}"
		
		# Determine target path
		local target_path
		if [[ "$relative_path" == .* ]]; then
			# Hidden files go to $HOME
			target_path="$HOME/$relative_path"
		else
			# Other files go to $HOME/.config
			target_path="$HOME/.config/$relative_path"
		fi
		
		# Create symlink
		create_symlink "$file" "$target_path" "$relative_path"
		
	done < <(find "$source_dir" -type f -print0)
}

install_dotfiles() {
	info "Installing dotfiles..."

	local DOTFILES_DIR="$ROOT_DIR/dotfiles"

	# Install dotfiles recursively
	if [ -d "$DOTFILES_DIR" ]; then
		install_dotfile_recursive "$DOTFILES_DIR" "$HOME"
	fi

	log "Dotfiles installation complete"
}
