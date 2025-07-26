#!/bin/bash

# bare-arch-chroot: Auto-Rice Script for Arch Linux (Chroot Phase)
# Inspired by Luke Smith's LARBS
# Philosophy: Suckless, bare metal, personal setup for chroot environment

# Static configuration
readonly DOTFILES_REPO="https://github.com/mscamargo/dotfiles"
readonly SCRIPT_DIR=$(pwd)
readonly PACKAGES_FILE="packages.csv"
readonly AUR_HELPER="paru"
readonly USERNAME="${1:-$(whoami)}"  # Allow username as argument

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Error handling
set -e
trap 'error "Script failed at line $LINENO"' ERR

# Logging functions
log() { echo -e "${GREEN}[LOG]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
info() { echo -e "${BLUE}[INFO]${NC} $*"; }

# Check if running in chroot
chrootcheck() {
    if [[ ! -f /proc/1/mountinfo ]] || ! grep -q "/ / " /proc/1/mountinfo; then
        error "This script should be run from within a chroot environment"
    fi
    
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root in chroot environment"
    fi
}

# Welcome message
welcome() {
    clear
    cat << 'EOF'
 ___  ___  ___  ___       ___  ___  ___  _ _ 
| . \|   || . \| __| ___ | . \| . \|  _|| | |
| _ /| . || . || _| |___||   /|  _/| |_ |   |
|___/|___|___|_|___|     |_|_||_|  |___|_|_|

Auto-Rice Script for Arch Linux (Chroot Phase)
Suckless philosophy, bare metal approach
EOF
    echo
    log "Welcome to bare-arch chroot setup"
    log "This will configure your Arch system during installation"
    log "Target user: $USERNAME"
    echo
    
    # Check if we're running from a pipe (curl | bash)
    if [[ -t 0 ]]; then
        read -p "Press ENTER to continue, or Ctrl+C to abort..."
    else
        warn "Running from pipe - continuing automatically in 3 seconds..."
        sleep 3
    fi
}

# Check if user exists
checkuser() {
    if ! id "$USERNAME" &>/dev/null; then
        error "User $USERNAME does not exist. Please create the user before running this script."
    fi
    
    info "User $USERNAME exists and will be configured"
}

# Refresh keyrings and update system
refreshkeys() {
    info "Refreshing keyrings..."
    pacman --noconfirm -S archlinux-keyring
    log "Keyring refreshed"
}

# Update system
updatearch() {
    info "Updating system packages..."
    pacman --noconfirm -Syu
    log "System updated"
}

# Configure swapfile
configureswap() {
    info "Configuring 8GB swapfile with aggressive swappiness..."
    
    local swapfile="/swapfile"
    local swap_size="8G"
    
    # Check if swapfile already exists
    if [[ -f "$swapfile" ]]; then
        warn "Swapfile already exists, skipping creation"
    else
        # Create swapfile
        info "Creating $swap_size swapfile..."
        fallocate -l "$swap_size" "$swapfile" || dd if=/dev/zero of="$swapfile" bs=1G count=8
        
        # Set correct permissions
        chmod 600 "$swapfile"
        
        # Make it swap
        mkswap "$swapfile"
        
        # Add to fstab for persistence
        if ! grep -q "$swapfile" /etc/fstab; then
            echo "$swapfile none swap defaults 0 0" >> /etc/fstab
            log "Added swapfile to /etc/fstab"
        fi
    fi
    
    # Enable swap
    swapon "$swapfile"
    
    # Configure aggressive swappiness (use swap as much as possible)
    info "Configuring maximum swappiness..."
    
    # Set swappiness to 100 (maximum - use swap as much as possible)
    echo "vm.swappiness=100" >> /etc/sysctl.conf
    
    # Set vfs_cache_pressure to 100 (aggressive cache clearing)
    echo "vm.vfs_cache_pressure=100" >> /etc/sysctl.conf
    
    # Apply settings immediately
    sysctl vm.swappiness=100
    sysctl vm.vfs_cache_pressure=100
    
    log "8GB swapfile configured with maximum swappiness (100)"
}

# Install base packages only (no AUR in chroot)
installbasepackages() {
    info "Installing base packages..."
    
    [[ ! -f "$PACKAGES_FILE" ]] && error "Packages file $PACKAGES_FILE not found"
    
    local installed_count=0
    local failed_count=0
    
    # Read and install packages one at a time
    while IFS=, read -r tag prog desc; do
        # Skip empty lines, comments, and AUR packages
        [[ -z "$prog" || "$prog" =~ ^[[:space:]]*# || "$tag" == "A" ]] && continue
        
        # Skip git repos for now (handle them separately)
        [[ "$tag" == "G" ]] && continue
        
        # Clean up program name (remove any extra whitespace)
        prog=$(echo "$prog" | xargs)
        
        info "Installing $prog..."
        if pacman --noconfirm -S "$prog"; then
            log "✓ $prog installed successfully"
            installed_count=$((installed_count + 1))
        else
            warn "✗ Failed to install $prog"
            failed_count=$((failed_count + 1))
        fi
    done < "$PACKAGES_FILE"
    
    log "Base packages installation complete: $installed_count installed, $failed_count failed"
}

# Setup user environment and clone repositories
setupuserenv() {
    info "Setting up user environment..."
    
    local user_home="/home/$USERNAME"
    local src_dir="$user_home/.local/src"
    
    # Create directories
    mkdir -p "$src_dir"
    
    # Clone dotfiles
    if [[ ! -d "$src_dir/dotfiles" ]]; then
        info "Cloning dotfiles..."
        git clone "$DOTFILES_REPO" "$src_dir/dotfiles"
        log "Dotfiles cloned"
    fi
    
    # Fix ownership
    chown -R "$USERNAME:$USERNAME" "$user_home"
    
    log "User environment set up"
}

# Configure user shell
configureshell() {
    info "Configuring user shell..."
    
    # Check if zsh is installed
    if ! command -v zsh &> /dev/null; then
        warn "zsh not found, skipping shell configuration"
        return
    fi
    
    # Set zsh as default shell for the user
    if chsh -s /bin/zsh "$USERNAME"; then
        log "✓ Set zsh as default shell for $USERNAME"
    else
        warn "Failed to set zsh as default shell for $USERNAME"
    fi
}

# Install dotfiles
installdotfiles() {
    info "Installing dotfiles..."
    
    local user_home="/home/$USERNAME"
    local dotfiles_dir="$user_home/.local/src/dotfiles"
    local prev_dir=$(pwd)
    
    if [[ ! -d "$dotfiles_dir" ]]; then
        warn "Dotfiles not found, skipping..."
        return
    fi
    
    # Run install script as user
    if [[ -f "$dotfiles_dir/install.sh" ]]; then
        chmod +x "$dotfiles_dir/install.sh"
        cd "$dotfiles_dir"
        sudo -u "$USERNAME" ./install.sh
        cd "$prev_dir"
        log "Dotfiles installed"
    else
        warn "No install.sh found in dotfiles repository"
    fi
    
    log "Dotfiles installation complete"
}

# Enable services (can't start in chroot)
enableservices() {
    info "Enabling system services..."
    
    local services=("NetworkManager")
    
    for service in "${services[@]}"; do
        if systemctl list-unit-files | grep -q "^$service.service"; then
            systemctl enable "$service"
            log "Enabled $service"
        else
            warn "Service $service not found"
        fi
    done
    
    log "System services enabled"
}

# Create post-install script for AUR packages
createpostinstall() {
    info "Creating post-install script for AUR packages..."
    
    local user_home="/home/$USERNAME"
    local post_script="$user_home/post-archinstall.sh"
    
    cat > "$post_script" << 'POSTEOF'
#!/bin/bash

# bare-arch post-install script
# Run this after first login to install AUR packages

readonly AUR_HELPER="paru"
readonly PACKAGES_FILE="packages.csv"

# Install paru
if ! command -v paru &> /dev/null; then
    echo "Installing paru..."
    cd /tmp
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
fi

# Install AUR packages
if [[ -f "$PACKAGES_FILE" ]]; then
    while IFS=, read -r tag prog desc; do
        [[ "$tag" != "A" ]] && continue
        [[ -z "$prog" || "$prog" =~ ^[[:space:]]*# ]] && continue
        
        echo "Installing $prog from AUR..."
        paru -S --noconfirm "$prog" 2>/dev/null || echo "Failed to install $prog"
    done < "$PACKAGES_FILE"
fi

# Enable user services
echo "Enabling PipeWire services..."
systemctl --user enable pipewire.service 2>/dev/null || true
systemctl --user enable pipewire-pulse.service 2>/dev/null || true
systemctl --user enable wireplumber.service 2>/dev/null || true

echo "AUR packages and user services configured!"
echo "You can delete this script now."
POSTEOF
    
    # Copy packages.csv to user home
    cp "$SCRIPT_DIR/$PACKAGES_FILE" "$user_home/"
    
    # Make executable and set ownership
    chmod +x "$post_script"
    chown "$USERNAME:$USERNAME" "$post_script" "$user_home/$PACKAGES_FILE"
    
    log "Post-install script created at $post_script"
}

# Final message
finalize() {
    clear
    log "Chroot installation complete!"
    echo
    cat << EOF
Your Arch system has been configured with:
- User '$USERNAME' configured
- Base packages installed (no AUR packages yet)
- System services enabled

IMPORTANT: After first boot and login, run:
/home/$USERNAME/post-archinstall.sh

This will install AUR packages and configure user services.
EOF
    echo
    info "You can now exit chroot and reboot"
    info "Don't forget to run the post-install script after first login!"
}

# Main execution
main() {
    chrootcheck
    welcome
    checkuser
    refreshkeys
    updatearch
    configureswap
    installbasepackages
    setupuserenv
    configureshell
    installdotfiles
    enableservices
    createpostinstall
    finalize
}

# Run main function
main "$@" 
