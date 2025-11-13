# Personal Workstation Sync

## Overview

Your personal `darren-workstation` machine can now be managed through the SifOS fleet while keeping it separate from your personal nixos-config repository.

## Three Approaches

### Option 1: Manage via SifOS (Recommended for Testing)

Use the `darren-workstation` machine type in SifOS:

```bash
# Test the configuration locally
cd /home/darren/sif-os
sudo nixos-rebuild test -I nixos-config=.

# Deploy via fleet (if machine is on Tailscale)
./fleet-deploy.sh -m darren-workstation -y

# Or use the sync script
./scripts/sync-personal-workstation.sh
```

### Option 2: Keep Using nixos-config (Current Setup)

Continue using your flake-based nixos-config with:
- COSMIC desktop support
- Home Manager integration  
- Agenix secrets management
- DankMaterialShell for niri

```bash
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#darren-workstation
```

### Option 3: Hybrid Approach

Use nixos-config for personal customizations, but import common SifOS modules:

```nix
# In ~/nixos-config/hosts/darren-workstation/configuration.nix
imports = [
  # Your existing imports
  ../common/default.nix
  
  # Import from SifOS
  /home/darren/sif-os/modules/shell.nix
  /home/darren/sif-os/modules/remote-access.nix
];
```

## Differences

| Feature | nixos-config | SifOS |
|---------|--------------|-------|
| Structure | Flakes with home-manager | Traditional configuration.nix |
| Desktop | COSMIC + niri-dms | GNOME (but customizable) |
| Secrets | agenix | Plain nix (for now) |
| Fleet Management | No | Yes (Tailscale + scripts) |
| Best For | Personal customization | Fleet consistency |

## darren-workstation Machine Type

The SifOS `darren-workstation` type includes:

**Development Tools:**
- Full language support: Python, Node.js, Rust, Go, Java, C++
- Build tools: make, cmake, pkg-config
- Version control: git, gitg

**Virtualization:**
- Docker
- Podman (without dockerCompat to avoid conflicts)

**Optional** (commented out, uncomment in `machine-types/darren-workstation.nix`):
- Database: PostgreSQL, MySQL Workbench
- Monitoring: Prometheus, Grafana
- TeamViewer

**Shell:**
- zsh with Oh My Zsh
- All development plugins enabled

## Sync Script Usage

```bash
./scripts/sync-personal-workstation.sh

# Options:
1) Deploy SifOS config to darren-workstation
2) Copy shell config from nixos-config to SifOS
3) Compare package lists
4) Show configuration differences
5) Exit
```

## Deployment Tips

1. **Test First**: Always use `nixos-rebuild test` before committing
2. **Check Tailscale**: Ensure machine is online: `tailscale status`
3. **Backup**: Consider backing up your current config: `cp -r /etc/nixos /etc/nixos.backup`

## Future Integration Ideas

- Import nixos-config as a flake input in SifOS
- Share common modules between both repos
- Use SifOS for base system, nixos-config for user environment
