# Machine Type Profiles
# Optional configurations based on machine purpose

This directory will contain optional configuration profiles based on machine type:

## Machine Types

### 1. Thin Client (`thin-client`)
**Use case:** Dispatch stations, RDP terminals, minimal desktop
**Features:**
- Lightweight GNOME or XFCE
- Remmina RDP client
- Auto-login to sif user
- Minimal packages
- Label printer support
- No sleep/suspend

**Example machines:**
- Dispatch stations
- RDP terminals
- Reception desks

### 2. Office (`office`)
**Use case:** Standard office workstation
**Features:**
- Full GNOME desktop
- LibreOffice suite
- Email client
- PDF reader
- Printer support
- Multi-user (no auto-login)

**Example machines:**
- Office desktops
- Meeting room PCs
- Admin workstations

### 3. Workstation (`workstation`)
**Use case:** Development, power users
**Features:**
- Full desktop environment
- Development tools (VS Code, Git, Docker)
- Multiple monitors support
- More RAM/resources
- Admin tools available

**Example machines:**
- Developer machines
- Design workstations
- Engineering PCs

### 4. Shop Kiosk (`shop-kiosk`)
**Use case:** Public-facing, locked down
**Features:**
- Locked-down desktop
- Single application focus
- No file manager
- Auto-start specific app
- Auto-reboot on failure
- Touchscreen support

**Example machines:**
- Shop floor terminals
- Self-service kiosks
- Information displays

### 5. Custom (`custom`)
**Use case:** Special purpose, manual configuration
**Features:**
- Base system only
- Manually configure as needed
- No presets applied

## Usage

During deployment, select the machine type:
```bash
./remote-deploy.sh -t 192.168.0.49
# Then select type from menu
```

Or specify directly:
```bash
./remote-deploy.sh -t 192.168.0.49 -h dispatch-01 -m thin-client
```

## Creating Type-Specific Configs

To create machine-type-specific features, create modules like:

```
machine-types/
├── thin-client.nix
├── office.nix
├── workstation.nix
└── shop-kiosk.nix
```

Then import in configuration.nix based on machine type.

## Current Implementation

For now, all machines use the base thin-client configuration. The machine type is stored for documentation and future expansion.

## Future Enhancements

- [ ] Separate module for each machine type
- [ ] Auto-import based on machine type
- [ ] Type-specific package sets
- [ ] Type-specific user configurations
- [ ] Type-specific security policies
