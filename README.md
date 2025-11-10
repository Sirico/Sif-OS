# SifOS - Thin Client Operating System

A NixOS-based operating system designed for thin client deployments on Wyse 5070 hardware and similar devices.

## Purpose

SifOS provides a standardized, remotely-manageable thin client environment for dispatch stations and similar use cases. It includes:

- **RDP Access**: Remmina for connecting to Windows VMs in Proxmox
- **Label Printing**: CUPS with label printer support
- **Remote Management**: SSH and Tailscale for secure remote access
- **Standardized Users**: Admin and sif user accounts
- **Auto-login**: Automatic login to sif user for thin client operation

## Hardware

Primary target: **Dell Wyse 5070 Thin Client**
- Intel CPU support
- Works on similar x86_64 thin client hardware

## Quick Start

**👉 For daily operations, see [docs/FLEET-MANAGEMENT.md](docs/FLEET-MANAGEMENT.md) or [docs/CHEATSHEET.md](docs/CHEATSHEET.md)**

### Deploy Your First Machine

```bash
# Interactive deployment (prompts for hostname and type)
./remote-deploy.sh -t 192.168.0.49

# Or specify everything
./remote-deploy.sh -t 192.168.0.49 -h dispatch-01 -m thin-client -y -a
```

### Test Before Pushing

```bash
# Test all machine types build successfully
./scripts/test-build.sh
```

### Make Configuration Changes

```bash
# 1. Edit files
vim modules/users.nix

# 2. Test the configuration
./scripts/test-build.sh

# 3. Test on one machine
./remote-deploy.sh -t 192.168.0.49 -h test -m thin-client -y

# 4. Commit and push
git add .
git commit -m "Added new user"
git push

# 5. Deploy to fleet
./scripts/deploy-fleet.sh -a
```

See [docs/FLEET-MANAGEMENT.md](docs/FLEET-MANAGEMENT.md) for complete workflow.

## Repository Structure

```
sifos/
├── configuration.nix              # Main NixOS configuration entry point
├── machine-config.nix             # Per-machine settings (hostname, type)
│
├── modules/                       # Core system modules
│   ├── users.nix                  # Admin and sif user accounts
│   ├── remote-access.nix          # SSH and Tailscale VPN
│   ├── printing.nix               # CUPS printing system
│   └── remmina.nix                # RDP client configuration
│
├── machine-types/                 # Machine type-specific configs
│   ├── thin-client.nix            # Minimal RDP desktop
│   ├── office.nix                 # Full productivity desktop
│   ├── workstation.nix            # Development environment
│   └── shop-kiosk.nix             # Locked-down kiosk
│
├── machines/                      # Fleet inventory
│   ├── inventory.txt              # List of all machines
│   └── template.nix               # Template for new machines
│
├── remmina-profiles/              # Pre-configured RDP profiles
│   └── windows-vm.remmina         # Windows VM connection
│
├── nixos/                         # Hardware-specific configs
│   └── hardware-configuration.nix # Generated per machine
│
├── scripts/                       # Deployment and utility scripts
│   ├── test-build.sh              # Test all configurations
│   ├── check-status.sh            # Check fleet status
│   ├── deploy-fleet.sh            # Deploy to multiple machines
│   └── test-config.sh             # Validate configuration
│
├── docs/                          # Documentation
│   ├── QUICKSTART.md              # Quick start guide
│   ├── DEPLOYMENT.md              # Deployment procedures
│   ├── FLEET-MANAGEMENT.md        # Fleet management guide
│   ├── TESTING.md                 # Testing procedures
│   ├── CHEATSHEET.md              # Command reference
│   ├── SECURITY.md                # Security model
│   └── PROJECT-SUMMARY.md         # Project overview
│
├── remote-deploy.sh               # Main deployment script
└── self-update.sh                 # On-machine update script
```

## Features

### Users

- **admin**: Administrator account with sudo access
  - SSH key authentication
  - Remote management tools
  - Wheel group member

- **sif**: Standard user account
  - Auto-login enabled
  - Printer access
  - Limited privileges

### Remote Access

- **SSH**: OpenSSH with keepalive
- **Tailscale**: VPN for secure remote access
- **Firewall**: Configured with SSH and Tailscale access

### Thin Client Features

- **Remmina**: RDP client for Windows VM connections
- **GNOME**: Desktop environment (minimal installation)
- **Auto-login**: Boots directly to sif user session
- **No sleep**: Suspend/hibernate disabled

### Printing

- **CUPS**: Print server with web interface
- **Avahi**: Network printer discovery
- **Label Printers**: Support for common label printer drivers

## Management

### Remote Access

```bash
# SSH access
ssh admin@thinclient-hostname

# Via Tailscale
ssh admin@thinclient-hostname.tailnet-name.ts.net
```

### Updating Configuration

```bash
# On the thin client
cd /etc/nixos
sudo git pull  # if using git
sudo nixos-rebuild switch
```

### Rollback

NixOS allows easy rollback to previous configurations:

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback
sudo nixos-rebuild switch --rollback
```

## Deployment Notes

### Per-Machine Customization

For each thin client, you may want to:

1. **Set unique hostname**: Edit `networking.hostName` in configuration.nix
2. **Generate hardware config**: Run `nixos-generate-config` on the hardware
3. **Configure printers**: Add specific printer configurations

### Creating Installation Media

To create a bootable USB for installation:

```bash
# Build ISO (on a NixOS machine)
nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=./iso.nix
```

### Network Installation

## Documentation

- **[Quick Start Guide](docs/QUICKSTART.md)** - Get started in 5 minutes
- **[Deployment Guide](docs/DEPLOYMENT.md)** - Detailed deployment procedures
- **[Fleet Management](docs/FLEET-MANAGEMENT.md)** - Managing multiple machines
- **[Testing Guide](docs/TESTING.md)** - How to test before pushing to GitHub
- **[Cheat Sheet](docs/CHEATSHEET.md)** - Common commands reference
- **[Security Model](docs/SECURITY.md)** - Security architecture and practices
- **[Project Summary](docs/PROJECT-SUMMARY.md)** - High-level overview

## Troubleshooting

### Auto-login not working

Check the display manager service:
```bash
systemctl status display-manager
```

### Tailscale not connecting

```bash
sudo tailscale up --accept-routes
sudo tailscale status
```

### Printer not found

```bash
sudo systemctl status cups
lpstat -p -d
```

### SSH connection drops

Keepalive is configured, but check network:
```bash
ping -c 4 8.8.8.8
sudo systemctl status sshd
```

## Contributing

When adding features or fixing issues:

1. **Test first**: Run `./scripts/test-build.sh` before committing
2. Test on a Wyse 5070 or similar hardware
3. Ensure remote management still works
4. Document any new configuration options
5. Keep the system lightweight for thin client use

See [docs/TESTING.md](docs/TESTING.md) for testing procedures.

## License

[Add your license here]

## Support

For issues or questions, contact the system administrator.
