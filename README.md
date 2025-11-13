# SifOS - Multi-Purpose NixOS System

A NixOS-based operating system designed for thin clients, office workstations, kiosks, and servers. Built for remote management and standardized deployments.

## Purpose

SifOS provides standardized, remotely-manageable system configurations for various use cases:

- **Thin Clients**: RDP stations with Remmina, auto-login, and minimal desktop
- **Office Workstations**: Full productivity environment with LibreOffice, development tools
- **Shop Kiosks**: Locked-down single-purpose terminals
- **Servers**: Headless systems with Cockpit, Podman, and web hosting capabilities
- **Development Workstations**: Full dev environment with multiple language support

### Key Features
- **Company Branding**: Dark theme with yellow accents, custom wallpapers and logos
- **Auto-login**: Thin clients boot directly to sif user with Remmina ready
- **Remote Management**: SSH and Tailscale VPN for secure remote access
- **Automated Backups**: Restic backup system for user data and application state
- **Label Printing**: CUPS with label printer support

## Hardware

Works on x86_64 hardware including:
- **Dell Wyse 5070 Thin Clients** (primary thin client target)
- **Dell OptiPlex 5070** (server configurations)
- **Standard x86_64 PCs** (office and workstation configurations)

## Quick Start

**👉 For daily operations, see [docs/FLEET-MANAGEMENT.md](docs/FLEET-MANAGEMENT.md) or [docs/CHEATSHEET.md](docs/CHEATSHEET.md)**

### Enroll a New Machine

```bash
# Enroll a fresh NixOS installation into the fleet
./enroll-machine.sh -t 192.168.0.50 -h thin-client-7 -m thin-client

# With Tailscale IP (if known)
./enroll-machine.sh -t 192.168.0.50 -h thin-client-7 -m thin-client -s 100.78.103.62

# Server enrollment
./enroll-machine.sh -t 192.168.0.100 -h server-1 -m server
```

### Deploy Your First Machine

```bash
# Single machine deployment via Tailscale
./remote-deploy.sh -t sifos-thin-client-6 -h thin-client-6 -m thin-client -y -a

# Or use local IP (if on same network)
./remote-deploy.sh -t 192.168.0.49 -h dispatch-01 -m thin-client -y -a

# Fleet deployment - list available machines
./fleet-deploy.sh -l

# Deploy to all thin clients
./fleet-deploy.sh -t thin-client -y

# Deploy to specific machine
./fleet-deploy.sh -m sifos-thin-client-6 -y

# Deploy to all machines (careful!)
./fleet-deploy.sh -a -y

# Interactive mode
./fleet-deploy.sh
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
./remote-deploy.sh -t sifos-thin-client-6 -h thin-client-6 -m thin-client -y

# 4. Commit and push
git add .
git commit -m "Added new user"
git push

# 5. Deploy to fleet via Tailscale
./fleet-deploy.sh -t thin-client -y
```

See [docs/FLEET-MANAGEMENT.md](docs/FLEET-MANAGEMENT.md) for complete workflow.

## Repository Structure

```
sifos/
├── configuration.nix              # Main NixOS configuration entry point
├── machine-config.nix             # Per-machine settings (hostname, type)
│
├── modules/                       # Core system modules
│   ├── users.nix                  # Admin and sif user accounts with keyring setup
│   ├── remote-access.nix          # SSH and Tailscale VPN
│   ├── printing.nix               # CUPS printing system
│   ├── branding.nix               # Company branding (dark theme, yellow accents)
│   └── backup.nix                 # Restic backup configuration
│
├── machine-types/                 # Machine type-specific configs
│   ├── thin-client.nix            # Minimal RDP desktop with Remmina auto-start
│   ├── office.nix                 # Full productivity desktop
│   ├── workstation.nix            # Development environment
│   ├── shop-kiosk.nix             # Locked-down kiosk
│   ├── server.nix                 # Headless server with Cockpit and Podman
│   └── custom.nix                 # Template for custom configurations
│
├── branding/                      # Company assets
│   ├── company-logo.png           # Company logo (100x100)
│   ├── plymouth-logo.png          # Boot splash logo
│   ├── user-icon.png              # User account icon
│   ├── wallpaper.jpg              # Desktop wallpaper
│   └── login-background.jpg       # Login screen background
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
│   ├── PROJECT-SUMMARY.md         # Project overview
│   └── machine-types/             # Machine type documentation
│       └── server.md              # Server configuration guide
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

- **Remmina**: Auto-starts on login for immediate RDP access
- **GNOME**: Dark theme with yellow accents, custom branding
- **Auto-login**: Boots directly to sif user session with keyring unlocked
- **No sleep**: Suspend/hibernate disabled
- **Company Branding**: Custom logos, wallpapers, and login backgrounds

### Office/Workstation Features

- **Full Desktop**: Complete GNOME environment with productivity tools
- **LibreOffice**: Complete office suite
- **Development Tools**: Git, VSCode, language runtimes
- **Multimedia**: Audio/video support

### Server Features

- **Cockpit**: Web management interface on port 9090
- **Podman**: Container runtime with Docker compatibility
- **Nginx**: Pre-configured reverse proxy
- **Monitoring**: Prometheus node exporter
- **Performance Tuned**: Optimized for server workloads

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

## Backup Strategy

### Configuration Backups (Automatic via Git)

Your NixOS configuration is automatically backed up to GitHub:
- Repository: `github.com/Sirico/sif-os`
- Every change is version controlled
- Easy to restore: just clone and deploy

### User Data Backups (Restic)

The backup module provides automated backups of:
- `/home/sif/` - User files, Remmina profiles, browser bookmarks
- `/home/admin/` - Admin user data
- `/var/lib/` - Application data and state

#### Enable Backups on a Machine

Add to your machine's configuration:

```nix
{
  imports = [
    ./modules/backup.nix
  ];

  sifos.backup = {
    enable = true;
    repository = "/mnt/backup";  # or "s3:s3.amazonaws.com/bucket"
    passwordFile = "/root/restic-password";
    schedule = "daily";  # or "weekly", "hourly", etc.
  };
}
```

#### Manual Backup Operations

```bash
# Run backup now
sudo sifos-backup

# List available snapshots
restic -r /mnt/backup -p /root/restic-password snapshots

# Restore a snapshot
sudo sifos-restore <snapshot-id> /tmp/restore

# Example: Restore user's home directory
sudo sifos-restore abc123 /tmp/restore
```

#### Setup Backup Repository

```bash
# Create password file (do this once per machine)
echo "your-secure-password" | sudo tee /root/restic-password
sudo chmod 600 /root/restic-password

# The repository will be initialized automatically on first backup
```

See [modules/backup.nix](modules/backup.nix) for advanced configuration options.

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
