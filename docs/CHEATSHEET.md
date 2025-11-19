# Quick Reference - SifOS Deployment

## 🚀 Deploy a Single Machine (Interactive)

```bash
./remote-deploy.sh -t 192.168.0.49
```

You'll be prompted for:
1. **Hostname** (e.g., `dispatch-01`, `office-pc-1`, `warehouse-kiosk`)
2. **Machine type**:
   - `thin-client` - Dispatch stations, RDP terminals
   - `office` - Standard office workstation
   - `workstation` - Development, power users
   - `shop-kiosk` - Public-facing, locked down
   - `custom` - Manual configuration

## 🎯 Deploy Non-Interactive (Automated)

```bash
# Test only (safe)
./remote-deploy.sh -t 192.168.0.49 -h dispatch-01 -m thin-client -y

# Apply immediately
./remote-deploy.sh -t 192.168.0.49 -h dispatch-01 -m thin-client -y -a
```

## 📊 Deploy Entire Fleet

1. **Edit inventory file**: `machines/inventory.txt`
   ```
   dispatch-01:192.168.0.49:thin-client:Dispatch Station 1
   dispatch-02:192.168.0.50:thin-client:Dispatch Station 2
   office-pc-1:192.168.0.60:office:Manager Office
   ```

2. **Deploy all machines**:
   ```bash
   # Test mode
   ../scripts/deploy-fleet.sh
   
   # Apply immediately
   ../scripts/deploy-fleet.sh -a
   ```

## 🔧 Configure Remmina RDP

1. **Edit profile**: `remmina-profiles/windows-vm.remmina`
   ```ini
   name=Dispatch VM - Main
   server=192.168.1.100:3389
   username=dispatcher
   ```

2. **Commit and push**:
   ```bash
   git add remmina-profiles/
   git commit -m "Configure RDP for dispatch VM"
   git push
   ```

3. **Profiles auto-install** on user's first login

## 📝 Make Configuration Changes

```bash
# 1. Edit files locally
vim modules/users.nix

# 2. Commit changes
git add .
git commit -m "Add new user account"

# 3. Push to GitHub
git push

# 4. Deploy to machines
./remote-deploy.sh -t 192.168.0.49 -h dispatch-01 -m thin-client -y -a

# Or update entire fleet
../scripts/deploy-fleet.sh -a
```

## 🔁 Sync Config to Existing Machines

Thin clients only see new settings after the repo has the change:

1. **Edit + commit + push** from your workstation (as above).
2. **On the thin client**:
   ```bash
   cd ~/sif-os
   git pull          # pulls the commit you just pushed
   sudo nixos-rebuild switch --flake .#thin-client-6
   ```
3. Verify the service (`systemctl status cups.service`, etc.).

If nothing changed upstream, `git pull` does nothing and the rebuild keeps the old config—always push before asking remote machines to rebuild.

## 🔍 Check Machine Status

```bash
# Single machine
../scripts/check-status.sh 192.168.0.49

# Multiple machines
../scripts/check-status.sh dispatch-01 dispatch-02 office-pc-1
```

## 🔄 Self-Update (On Machine)

```bash
# SSH to machine
ssh admin@192.168.0.49

# Update from GitHub
sudo /etc/sifos/self-update.sh -a
```

## 📋 Machine Types

| Type | Use Case | Features |
|------|----------|----------|
| **thin-client** | Dispatch, RDP terminals | Minimal, Remmina, auto-login |
| **office** | Standard desktop | Full GNOME, LibreOffice, email |
| **workstation** | Development | Dev tools, VS Code, Docker |
| **shop-kiosk** | Public terminals | Locked down, single app |
| **custom** | Special purpose | Manual configuration |

## 🆘 Common Tasks

### Deploy First Machine
```bash
./remote-deploy.sh -t 192.168.0.49
# Enter hostname: dispatch-01
# Select type: 1 (thin-client)
# Confirm: y
```

### Add Machine to Inventory
Edit `machines/inventory.txt`:
```
new-machine:192.168.0.51:thin-client:New Location
```

### Update Single Machine
```bash
./remote-deploy.sh -t 192.168.0.49 -h dispatch-01 -m thin-client -y -a
```

### Rollback on Machine
```bash
ssh admin@machine
sudo nixos-rebuild switch --rollback
```

### View Machine Configuration
```bash
ssh admin@machine
cat /etc/nixos/machine-config.nix
```

## 🔐 Security Notes

- Scripts require `sudo` (admin only)
- Regular users cannot update system
- All updates tracked in Git
- Passwords never committed

## 📚 Full Documentation

- **README.md** - Complete system overview
- **QUICKSTART.md** - Setup guide
- **FLEET-MANAGEMENT.md** - Workflow details
- **SECURITY.md** - Security model
- **DEPLOYMENT.md** - Deployment checklist
- **remmina-profiles/README.md** - RDP configuration
- **machine-types/README.md** - Machine type details
