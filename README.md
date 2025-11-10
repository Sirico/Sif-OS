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

**👉 For daily operations, see [FLEET-MANAGEMENT.md](FLEET-MANAGEMENT.md) or [CHEATSHEET.md](CHEATSHEET.md)**

### Deploy Your First Machine

```bash
# Interactive deployment (prompts for hostname and type)
./remote-deploy.sh -t 192.168.0.49

# Or specify everything
./remote-deploy.sh -t 192.168.0.49 -h dispatch-01 -m thin-client -y -a
```

### Make Configuration Changes

```bash
# 1. Edit files
vim modules/users.nix

# 2. Test on one machine
./remote-deploy.sh -t 192.168.0.49 -h test -m thin-client -y

# 3. Commit and push
git add .
git commit -m "Added new user"
git push

# 4. Deploy to fleet
./deploy-fleet.sh -a
```

See [FLEET-MANAGEMENT.md](FLEET-MANAGEMENT.md) for complete workflow.

### Original Setup (First Time Only)

For the initial NixOS installation on new hardware:

```bash
# Copy configuration to target machine
scp -r configuration.nix modules/ nixos/ root@target-machine:/etc/nixos/

# Or if using the provided hardware-configuration.nix
scp configuration.nix modules/* root@target-machine:/etc/nixos/
```

### 2. Customize Configuration

Before deploying, edit these files:

**modules/users.nix**:
- Add your SSH public key to the admin user
- Change the sif user's initial password

**configuration.nix**:
- Set the hostname for each thin client

### 3. Build and Deploy

```bash
# On the target machine
sudo nixos-rebuild switch

# Or test first
sudo nixos-rebuild test
```

### 4. Post-Installation

**Connect to Tailscale** (first time only):
```bash
sudo tailscale up
```

**Set passwords**:
```bash
sudo passwd admin
sudo passwd sif
```

## Structure

```
sifos/
├── configuration.nix              # Main configuration
├── nixos/
│   └── hardware-configuration.nix # Hardware-specific config
└── modules/
    ├── users.nix                  # User accounts
    ├── thin-client.nix            # Desktop environment
    ├── remote-access.nix          # SSH & Tailscale
    └── printing.nix               # CUPS & label printers
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

For remote installation on existing NixOS machines:

```bash
# Copy configuration
scp -r . admin@target:/tmp/sifos-config/

# Apply configuration
ssh admin@target 'sudo cp -r /tmp/sifos-config/* /etc/nixos/ && sudo nixos-rebuild switch'
```

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

1. Test on a Wyse 5070 or similar hardware
2. Ensure remote management still works
3. Document any new configuration options
4. Keep the system lightweight for thin client use

## License

[Add your license here]

## Support

For issues or questions, contact the system administrator.
