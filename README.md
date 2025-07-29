# Auto-Rice Script for Arch Linux

## Quick Start (Single Command)

Run the entire setup with one command (username is required):

```bash
# Using curl
curl -sSL https://raw.githubusercontent.com/mscamargo/archinstall/main/run.sh | bash -s yourusername

# Using wget
wget -qO- https://raw.githubusercontent.com/mscamargo/archinstall/main/run.sh | bash -s yourusername
```

## Manual Installation

If you prefer to clone the repository first:

```bash
git clone https://github.com/mscamargo/archinstall
cd archinstall
./run.sh username  # replace 'username' with desired username
```

## How It Works

The script downloads installation files and creates a manual installation script in the user's home directory. After setup:

1. **Reboot and login** as the configured user
2. **Run the installation script** manually: `~/bare-arch-install.sh`
3. **Wait for completion** - The script will install all packages and configurations
4. **Clean up** - Delete the script after installation

## Prerequisites

- User account must exist before running the script
- Must be run as root to set up the installation files
- User must have sudo privileges for package installation

## What This Does

This script automatically configures your Arch Linux system with:
- System updates and keyring refresh
- Base packages installation (via pacman)
- AUR helper installation (paru)
- AUR packages installation
- Suckless software (dwm, st, dmenu, surf)
- Dotfiles installation and configuration
- User services configuration (PipeWire, etc.)
- Shell configuration (zsh)
- Swap file configuration

## Installation Process

1. **Setup Phase** (run as root):
   - Downloads installation files to user's home directory
   - Creates manual installation script
   - Sets proper permissions and ownership

2. **Installation Phase** (run manually by user):
   - Updates system packages
   - Installs all base and AUR packages
   - Configures user environment
   - Installs and configures dotfiles
   - Enables user services

## Files Created

- `/home/username/.local/share/bare-arch/` - Installation files
- `/home/username/bare-arch-install.sh` - Manual installation script

After installation, you can delete the script with:
```bash
rm ~/bare-arch-install.sh
```

