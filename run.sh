#!/bin/bash

# bare-arch bootstrap script
# This script can be run with: curl -sSL https://raw.githubusercontent.com/mscamargo/archinstall/main/run.sh | bash -s username

set -e

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Logging functions
log() { echo -e "${GREEN}[LOG]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
info() { echo -e "${BLUE}[INFO]${NC} $*"; }

# Configuration
readonly REPO_URL="https://github.com/mscamargo/archinstall"
readonly INSTALL_DIR="$HOME/.local/share/bare-arch"

# Check if username is provided
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <username>"
    echo "Example: $0 john"
    exit 1
fi

readonly USERNAME="$1"

# Welcome message
welcome() {
    clear
    cat << 'EOF'
 ___  ___  ___  ___       ___  ___  ___  _ _ 
| . \|   || . \| __| ___ | . \| . \|  _|| | |
| _ /| . || . || _| |___||   /|  _/| |_ |   |
|___/|___|___|_|___|     |_|_||_|  |___|_|_|

Auto-Rice Script for Arch Linux
Suckless philosophy, bare metal approach
EOF
    echo
    log "Welcome to bare-arch bootstrap"
    log "This will download and set up the bare-arch project"
    log "Target user: $USERNAME"
    echo
    read -p "Press ENTER to continue, or Ctrl+C to abort..."
}

# Check if running in chroot
chrootcheck() {
    if [[ ! -f /proc/1/mountinfo ]] || ! grep -q "/ / " /proc/1/mountinfo; then
        error "This script should be run from within a chroot environment"
    fi
    
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root in chroot environment"
    fi
}

# Download project files
download_project() {
    info "Downloading bare-arch project files..."
    
    # Create installation directory
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    # Download individual files
    local files=("install.sh" "packages.csv" "README.md" "LICENSE")
    
    for file in "${files[@]}"; do
        info "Downloading $file..."
        if curl -sSL -o "$file" "$REPO_URL/raw/main/$file"; then
            log "✓ Downloaded $file"
        else
            error "Failed to download $file"
        fi
    done
    
    # Make install script executable
    chmod +x install.sh
    
    log "Project files downloaded to $INSTALL_DIR"
}

# Run the installation
run_installation() {
    info "Starting bare-arch installation..."
    cd "$INSTALL_DIR"
    ./install.sh "$USERNAME"
}

# Main execution
main() {
    chrootcheck
    welcome
    download_project
    run_installation
}

# Run main function
main "$@" 