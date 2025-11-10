# SifOS Machine Types

This directory contains machine-type-specific configurations for different use cases. Each machine type provides a tailored set of features, packages, and behaviors.

## Available Machine Types

### 1. Thin Client (`thin-client.nix`)
**Purpose**: Minimal desktop for dispatch stations and RDP-only terminals

**Features:**
- Minimal GNOME desktop (unnecessary apps removed)
- Remmina RDP client for Windows VM connections
- Auto-login as `sif` user
- No automatic sleep/suspend
- Tailscale and SSH for remote support
- Label printer support

**Use Cases:**
- Dispatch stations
- Remote desktop terminals
- Warehouse check-in/out stations
- Point-of-use RDP terminals

**Typical Locations**: Warehouse dispatch, reception desks, shop floor stations

---

### 2. Office Desktop (`office.nix`)
**Purpose**: Full productivity desktop for office workers

**Features:**
- Complete GNOME desktop environment
- LibreOffice Suite (Writer, Calc, Impress)
- Thunderbird email client
- PDF viewer (Evince)
- Firefox web browser
- Remmina for RDP connections
- Multi-user support (no auto-login)
- Normal power management (sleep enabled)
- Network printing support

**Use Cases:**
- Office desktops
- Administrative workstations
- Multi-user machines
- General productivity work

**Typical Locations**: Main office, admin areas, meeting rooms

---

### 3. Workstation (`workstation.nix`)
**Purpose**: Development and power-user workstation

**Features:**
- Full GNOME desktop environment
- VS Code / VSCodium IDE
- Docker and Docker Compose
- Development tools (Python, Node.js, Git)
- Chromium browser (for web development)
- Wireshark (network analysis)
- LibreOffice Suite
- Multi-user support
- Normal power management
- Increased system resources expected

**Use Cases:**
- Software development
- DevOps work
- Network administration
- IT department workstations
- Testing and staging

**Typical Locations**: IT office, development area, system admin desks

---

### 4. Shop Kiosk (`shop-kiosk.nix`)
**Purpose**: Locked-down public terminals for shop floor

**Features:**
- Minimal XFCE desktop (lightweight)
- Auto-login as `sif` user
- Firefox browser
- No sleep/screensaver (always on)
- No window decorations
- Daily automatic reboot at 3 AM
- Locked-down user experience
- No power buttons in UI
- Tailscale/SSH for remote support

**Use Cases:**
- Shop floor terminals
- Public kiosks
- Time clock stations
- Self-service portals
- Display-only stations

**Typical Locations**: Shop floor, warehouse, factory floor, public areas

---

### 5. Custom (`custom`)
**Purpose**: Base system without type-specific configuration

**Features:**
- Base users and remote access only
- No desktop environment presets
- Manually configure as needed
- Good for special-purpose machines

**Use Cases:**
- Servers or headless systems
- Special-purpose machines
- Testing new configurations
- Machines that don't fit other types

---

## Choosing a Machine Type

Use this guide to select the appropriate type:

| Need                          | Machine Type    |
|-------------------------------|-----------------|
| RDP only, minimal desktop     | `thin-client`   |
| General office work           | `office`        |
| Development/IT work           | `workstation`   |
| Public/locked-down terminal   | `shop-kiosk`    |
| Custom requirements           | `custom`        |

## Deployment

Machine types are selected during deployment with `remote-deploy.sh`:

```bash
# Interactive mode (prompts for machine type)
./remote-deploy.sh -t 192.168.0.49

# Non-interactive mode
./remote-deploy.sh -t 192.168.0.49 -h dispatch-01 -m thin-client -a
```

The selected machine type is imported in `machine-config.nix` and determines which features are enabled on the machine.

## Machine Type Comparison

| Feature                    | Thin Client | Office | Workstation | Shop Kiosk | Custom |
|----------------------------|-------------|--------|-------------|------------|--------|
| Desktop Environment        | GNOME Mini  | GNOME  | GNOME       | XFCE       | None   |
| Auto-Login                 | ✓           | ✗      | ✗           | ✓          | ✗      |
| LibreOffice                | ✗           | ✓      | ✓           | ✗          | ✗      |
| Development Tools          | ✗           | ✗      | ✓           | ✗          | ✗      |
| Docker                     | ✗           | ✗      | ✓           | ✗          | ✗      |
| Email Client               | ✗           | ✓      | ✗           | ✗          | ✗      |
| Multi-User                 | ✗           | ✓      | ✓           | ✗          | ✓      |
| Sleep/Suspend              | Disabled    | Normal | Normal      | Disabled   | Normal |
| Auto-Reboot                | ✗           | ✗      | ✗           | Daily 3AM  | ✗      |
| Window Decorations         | ✓           | ✓      | ✓           | ✗          | N/A    |
| Remote Access (SSH/TS)     | ✓           | ✓      | ✓           | ✓          | ✓      |
| Printing                   | ✓           | ✓      | ✓           | ✓          | ✓      |

## Customization

### Per-Machine Customization

Edit `/etc/nixos/machine-config.nix` on the deployed machine to:
- Change the imported machine type module
- Set static IP addresses
- Add machine-specific settings

Example:
```nix
# Change from thin-client to office
imports = [
  ./machine-types/office.nix
];
```

### Fleet-Wide Customization

Edit the machine type modules in this directory (`machine-types/*.nix`) to change defaults for all machines of that type. Push changes to GitHub and run `self-update.sh` on deployed machines to apply.

## Adding New Machine Types

To create a new machine type:

1. Copy an existing type as a template:
   ```bash
   cp machine-types/thin-client.nix machine-types/my-new-type.nix
   ```

2. Edit the new module to add/remove features

3. Update `remote-deploy.sh` to include the new type in the menu (around line 90)

4. Update this README with the new type documentation

5. Commit and push to GitHub:
   ```bash
   git add machine-types/my-new-type.nix
   git commit -m "Add new machine type: my-new-type"
   git push
   ```

6. Deploy to test machine:
   ```bash
   ./remote-deploy.sh -t 192.168.0.49 -h test-01 -m my-new-type
   ```

## Technical Details

- Machine types are NixOS modules that are imported in `machine-config.nix`
- Each type module can:
  - Enable/disable services
  - Install packages
  - Configure display managers
  - Set power management policies
  - Create systemd units (like daily reboot)
  - Configure desktop environments

- All types include (from base modules):
  - Two-user setup (admin/sif)
  - Tailscale VPN
  - SSH remote access
  - CUPS printing
  - Firefox browser
  - Remmina RDP client

- Types build on top of base configuration in `modules/`:
  - `modules/users.nix` - User accounts
  - `modules/remote-access.nix` - SSH and Tailscale
  - `modules/printing.nix` - CUPS printing
  - `modules/remmina.nix` - RDP profiles

## See Also

- [Deployment Guide](../DEPLOYMENT.md)
- [Fleet Management](../FLEET-MANAGEMENT.md)
- [Quick Start](../QUICKSTART.md)
- [Project Summary](../PROJECT-SUMMARY.md)

