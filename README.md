# bare-arch: Auto-Rice Script for Arch Linux

**Inspired by [Luke Smith's LARBS](https://github.com/LukeSmithxyz/LARBS)**

A simple, focused script for automatically configuring fresh Arch Linux installations following suckless principles. No unnecessary configuration options - just pure, personal automation.

## Installation

During Arch Linux installation, after chrooting into your new system:

```bash
git clone https://github.com/mscamargo/bare-arch
cd bare-arch
./bare-arch username  # replace 'username' with desired username
```

Then after first boot, login and run:
```bash
~/bare-arch-post-install.sh
```

That's it.

## What it does

**bare-arch** automatically installs and configures:

- **Base system**: Updates packages, installs essential tools
- **AUR helper**: Installs and configures `paru`
- **Programs**: All packages from `progs.csv` (pacman + AUR)
- **Suckless software**: dwm, st, dmenu, surf from your personal repo
- **Dotfiles**: Your personal configurations and symbolic links
- **Services**: NetworkManager, display manager, and other essentials

## Program List

The script uses `progs.csv` with the LARBS format:

- **Column 1**: Tag (empty = pacman, `A` = AUR, `G` = git repo)
- **Column 2**: Program name
- **Column 3**: Description

Example:
```csv
,firefox,web browser
A,paru,AUR helper for installing packages
G,https://github.com/user/repo,custom software
```

## Customization

### Personal Configuration

Edit the constants at the top of `bare-arch`:

```bash
readonly DOTFILES_REPO="https://github.com/mscamargo/dotfiles"
readonly SUCKLESS_REPO="https://github.com/mscamargo/suckless-software"
```

### Adding Programs

Edit `progs.csv` to add/remove programs. The script will:
- Install packages from official repos (no tag)
- Install AUR packages with `paru` (tag: `A`)
- Clone and build git repos (tag: `G`)

## Philosophy

Following the suckless philosophy:
- **Simple**: One script, one command, done
- **Personal**: No configuration files, no options - hardcoded for you
- **Focused**: Does exactly what you need, nothing more
- **Minimal**: Clean, readable bash code

## Requirements

- Fresh Arch Linux installation
- Internet connection
- User with sudo privileges

## Structure

```
bare-arch/
├── bare-arch         # Installation script
├── progs.csv         # Program list
├── README.md         # This file
└── LICENSE           # MIT
```

## How it works

1. **Checks**: Ensures running as root in chroot
2. **User**: Creates user account with sudo access
3. **Updates**: Refreshes keyrings and updates system
4. **Base packages**: Installs only official repo packages
5. **Repositories**: Clones suckless software and dotfiles to `~/.local/src`
6. **Suckless**: Builds and installs dwm, st, dmenu, surf
7. **Dotfiles**: Installs configurations as user
8. **Services**: Enables system services
9. **Post-script**: Creates script for AUR packages after first boot

## Inspired by LARBS

This script takes inspiration from [Luke Smith's LARBS](https://github.com/LukeSmithxyz/LARBS) but is:
- **Personal**: No configuration options, hardcoded for specific use
- **Simpler**: Focused on essential functionality
- **Direct**: No extra features, just what's needed

While no code was directly copied, the following concepts were inspired by LARBS:

- **CSV program format**: Three-column format with tags, program names, and descriptions
- **Installation workflow**: General approach to automated Arch Linux configuration
- **Suckless philosophy**: Focus on simplicity and functionality over aesthetics
- **Script structure**: Function-based organization and error handling patterns

**Key differences from LARBS:**
- All code written from scratch with independent implementations
- MIT License vs GPL-3 for broader compatibility
- Personal focus without configuration options
- Modern package choices (PipeWire instead of PulseAudio)
- Chroot-based installation during Arch setup

Special thanks to Luke Smith for pioneering automated rice scripts and inspiring the broader community to embrace suckless principles.

## License

MIT - More permissive than LARBS

---

*"Programs must be written for people to read, and only incidentally for machines to execute."* - Harold Abelson