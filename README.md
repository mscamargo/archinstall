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
./install.sh username  # replace 'username' with desired username
```

## Post-Installation

After first boot, login and run:
```bash
~/post-archinstall.sh
```

That's it.

## Prerequisites

- User account must exist before running the script
- Must be run as root in a chroot environment

## What This Does

This script automatically configures your Arch Linux system with:
- User configuration
- Base packages installation
- Suckless software (dwm, st, dmenu, surf)
- Dotfiles installation
- System services configuration
- AUR packages (via post-install script)

