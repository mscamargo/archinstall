#!/bin/bash

# bare-arch-chroot: Auto-Rice Script for Arch Linux (Chroot Phase)
# Inspired by Luke Smith's LARBS
# Philosophy: Suckless, bare metal, personal setup for chroot environment

# Static configuration
readonly DOTFILES_REPO="https://github.com/mscamargo/dotfiles"
readonly SUCKLESS_REPO="https://github.com/mscamargo/suckless-software"
readonly SCRIPT_DIR=$(pwd)
readonly PROGS_FILE="progs.csv"
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
    read -p "Press ENTER to continue, or Ctrl+C to abort..."
}

# Create user if it doesn't exist
createuser() {
    if id "$USERNAME" &>/dev/null; then
        info "User $USERNAME already exists"
        return
    fi
    
    info "Creating user $USERNAME..."
    useradd -m -G wheel,audio,video,storage -s /bin/bash "$USERNAME"
    
    # Set password
    echo "Set password for $USERNAME:"
    passwd "$USERNAME"
    
    # Add to sudoers
    echo "$USERNAME ALL=(ALL) ALL" >> /etc/sudoers.d/99-"$USERNAME"
    
    log "User $USERNAME created successfully"
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

# Install base packages only (no AUR in chroot)
installbasepackages() {
    info "Installing base packages..."
    
    [[ ! -f "$PROGS_FILE" ]] && error "Programs file $PROGS_FILE not found"
    
    local installed_count=0
    local failed_count=0
    
    # Read and install packages one at a time
    while IFS=, read -r tag prog desc; do
        # Skip empty lines, comments, and AUR packages
        [[ -z "$prog" || "$prog" =~ ^[[:space:]]*# || "$tag" == "A" ]] && continue
        
        # Skip git repos for now (handle them separately)
        [[ "$tag" == "G" ]] && continue
        
        info "Installing $prog..."
        if pacman --noconfirm -S "$prog" 2>/dev/null; then
            log "✓ $prog installed successfully"
            ((installed_count++))
        else
            warn "✗ Failed to install $prog"
            ((failed_count++))
        fi
    done < "$PROGS_FILE"
    
    log "Base packages installation complete: $installed_count installed, $failed_count failed"
}

# Setup user environment and clone repositories
setupuserenv() {
    info "Setting up user environment..."
    
    local user_home="/home/$USERNAME"
    local src_dir="$user_home/.local/src"
    
    # Create directories
    mkdir -p "$src_dir"
    
    # Clone suckless software
    if [[ ! -d "$src_dir/suckless-software" ]]; then
        info "Cloning suckless software..."
        git clone "$SUCKLESS_REPO" "$src_dir/suckless-software"
        log "Suckless software cloned"
    fi
    
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

# Install suckless software
installsuckless() {
    info "Installing suckless software..."
    
    local user_home="/home/$USERNAME"
    local suckless_dir="$user_home/.local/src/suckless-software"
    
    if [[ ! -d "$suckless_dir" ]]; then
        warn "Suckless software not found, skipping..."
        return
    fi
    
    cd "$suckless_dir"
    
    # Install each suckless program
    local suckless_progs=("dwm" "st" "dmenu" "surf")
    
    for prog in "${suckless_progs[@]}"; do
        if [[ -d "$prog" ]]; then
            info "Installing $prog..."
            cd "$prog"
            make clean install
            cd ..
            log "$prog installed successfully"
        else
            warn "$prog directory not found"
        fi
    done
    
    log "Suckless software installation complete"
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
    
    local services=("NetworkManager" "gdm")
    
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
    local post_script="$user_home/bare-arch-post-install.sh"
    
    cat > "$post_script" << 'POSTEOF'
#!/bin/bash

# bare-arch post-install script
# Run this after first login to install AUR packages

readonly AUR_HELPER="paru"
readonly PROGS_FILE="progs.csv"

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
if [[ -f "$PROGS_FILE" ]]; then
    while IFS=, read -r tag prog desc; do
        [[ "$tag" != "A" ]] && continue
        [[ -z "$prog" || "$prog" =~ ^[[:space:]]*# ]] && continue
        
        echo "Installing $prog from AUR..."
        paru -S --noconfirm "$prog" 2>/dev/null || echo "Failed to install $prog"
    done < "$PROGS_FILE"
fi

# Enable user services
echo "Enabling PipeWire services..."
systemctl --user enable pipewire.service 2>/dev/null || true
systemctl --user enable pipewire-pulse.service 2>/dev/null || true
systemctl --user enable wireplumber.service 2>/dev/null || true

echo "AUR packages and user services configured!"
echo "You can delete this script now."
POSTEOF
    
    # Copy progs.csv to user home
    cp "$SCRIPT_DIR/$PROGS_FILE" "$user_home/"
    
    # Make executable and set ownership
    chmod +x "$post_script"
    chown "$USERNAME:$USERNAME" "$post_script" "$user_home/$PROGS_FILE"
    
    log "Post-install script created at $post_script"
}

# Final message
finalize() {
    clear
    log "Chroot installation complete!"
    echo
    cat << EOF
Your Arch system has been configured with:
- User '$USERNAME' created with sudo access
- Base packages installed (no AUR packages yet)
- Suckless software built and installed
- Dotfiles installed
- System services enabled

IMPORTANT: After first boot and login, run:
/home/$USERNAME/bare-arch-post-install.sh

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
    createuser
    refreshkeys
    updatearch
    installbasepackages
    setupuserenv
    installsuckless
    installdotfiles
    enableservices
    createpostinstall
    finalize
}

# Run main function
main "$@" 