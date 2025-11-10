# Fleet Management Workflow

## Overview

SifOS uses a **GitHub-centric deployment model** where:
1. You make changes on your workstation
2. Push to GitHub
3. Deploy to machines from GitHub (not your local copy)

This ensures all machines get the same configuration and you have full audit trail.

## � Quick Start: Setting Up Your First Machine

```bash
# 1. Deploy from your workstation (interactive)
./remote-deploy.sh -t 192.168.0.49
# Enter hostname: dispatch-01
# Select type: 1 (thin-client)
# Confirm: y

# 2. After test succeeds, apply it
./remote-deploy.sh -t 192.168.0.49 -h dispatch-01 -m thin-client -y -a

# 3. SSH to machine and set up Tailscale
ssh admin@192.168.0.49
sudo tailscale up
```

That's it! Your machine is ready. 🎉

## ✅ Checking Everything Works

```bash
# Check machine status
../scripts/check-status.sh 192.168.0.49

# SSH and verify services
ssh admin@192.168.0.49
systemctl status sshd      # SSH working?
systemctl status gdm       # Desktop running?
systemctl status cups      # Printing ready?
hostname                   # Correct name?

# Test Remmina (as sif user)
# Login to desktop and launch Remmina from apps
```

## �🔄 Daily Workflow

### Making Changes

1. **Edit configuration locally** (on your workstation)
   ```bash
   cd /home/darren/sif-os
   vim modules/users.nix  # or any file
   ```

2. **Test locally** (optional but recommended)
   ```bash
   # If you have a local NixOS VM or machine
   ./test-config.sh
   ```

3. **Commit changes**
   ```bash
   git add .
   git commit -m "Description of changes"
   ```

4. **Push to GitHub**
   ```bash
   git push
   ```

5. **Deploy to fleet** (see deployment methods below)

## 🚀 Deployment Methods

### Method 1: Push from Workstation (Remote)

Deploy to a specific machine from your workstation:

```bash
# Test only (doesn't apply permanently)
./remote-deploy.sh -t 192.168.0.49 -h dispatch-01

# Apply immediately
./remote-deploy.sh -t 192.168.0.49 -h dispatch-01 -a
```

**When to use:**
- Initial deployment to new machines
- Emergency updates
- When you're not at the machine

### Method 2: Pull on Machine (Self-Update)

On the thin client itself (or via SSH):

```bash
# Test only
sudo /etc/sifos/self-update.sh

# Apply immediately
sudo /etc/sifos/self-update.sh -a
```

**When to use:**
- Machine requests update
- Scheduled updates (via cron)
- User-initiated updates

### Method 3: Bulk Update (Multiple Machines)

Create a script for updating multiple machines:

```bash
# Update all machines in inventory
for machine in dispatch-01 dispatch-02 dispatch-03; do
    ./remote-deploy.sh -t $machine -h $machine -a
done
```

## 📋 Common Scenarios

### Scenario 1: Add New User

1. Edit `modules/users.nix` on workstation
2. Commit: `git commit -am "Add new user account"`
3. Push: `git push`
4. Deploy to fleet: `../scripts/deploy-fleet.sh` (or manually to each machine)

### Scenario 2: Update Remmina Configuration

1. Edit `modules/remmina.nix`
2. Commit and push
3. Deploy to affected machines

### Scenario 3: Emergency Fix

1. Make fix locally
2. Test on one machine: `./remote-deploy.sh -t test-machine -h test-01`
3. If successful, push: `git push`
4. Deploy to fleet

### Scenario 4: Rollback Bad Update

On the affected machine:

```bash
# Rollback to previous NixOS generation
sudo nixos-rebuild switch --rollback

# Or restore from backup
sudo cp -r /etc/nixos.backup.YYYYMMDD-HHMMSS/* /etc/nixos/
sudo nixos-rebuild switch
```

## 🔍 Checking Fleet Status

### Single Machine
```bash
../scripts/check-status.sh 192.168.0.49
```

### Multiple Machines
```bash
../scripts/check-status.sh dispatch-01 dispatch-02 dispatch-03
```

### Via SSH
```bash
ssh admin@machine "nixos-version && hostname"
```

## 📦 Version Management

### Tagging Releases

Create tags for major changes:

```bash
git tag -a v1.1 -m "Added printer support for new models"
git push --tags
```

### Deploy Specific Version

```bash
# Modify remote-deploy.sh to use a specific tag
BRANCH="v1.1"  # Instead of "main"
```

## 🔐 Security Best Practices

1. **Always test before deploying to production**
   ```bash
   ./remote-deploy.sh -t test-machine -h test-01
   ```

2. **Review changes before pushing**
   ```bash
   git diff
   git log -p
   ```

3. **Use branches for experimental features**
   ```bash
   git checkout -b experimental-feature
   # make changes
   git push -u origin experimental-feature
   ```

4. **Never commit secrets**
   - Don't commit passwords in plain text
   - Use NixOS secrets management
   - Keep `.gitignore` updated

## 🛠️ Troubleshooting

### Can't Deploy - SSH Issues
```bash
# Verify SSH works
ssh admin@machine

# Check SSH key is added
ssh-add -l

# Re-add key if needed
ssh-add ~/.ssh/id_ed25519
```

### Configuration Won't Build
```bash
# Check syntax locally
nix-instantiate --parse configuration.nix

# Get detailed error
ssh admin@machine "cd /etc/nixos && sudo nixos-rebuild switch --show-trace"
```

### GitHub Push Rejected
```bash
# Pull first, then push
git pull --rebase
git push
```

### Machine Out of Sync
```bash
# Force update from GitHub
ssh admin@machine "sudo /etc/sifos/self-update.sh -a"
```

## 📊 Inventory Management

Keep a spreadsheet or file tracking:

| Hostname | IP | Location | Last Updated | Notes |
|----------|----|-----------:|--------------|-------|
| sifos-dispatch-01 | 192.168.0.49 | Office A | 2025-11-10 | Test machine |
| sifos-dispatch-02 | 192.168.0.50 | Office B | 2025-11-10 | |

Or create `machines/inventory.txt`:
```
dispatch-01:192.168.0.49:Office A
dispatch-02:192.168.0.50:Office B
```

## 🤖 Automation Ideas

### Scheduled Updates (on machines)

Add to cron:
```bash
# Daily at 2 AM - check for updates
0 2 * * * /etc/sifos/self-update.sh -a >> /var/log/sifos-update.log 2>&1
```

### Webhook-Triggered Updates

Set up GitHub Actions to notify machines when updates are pushed.

### Health Checks

Regular status checks:
```bash
#!/bin/bash
# health-check.sh
for machine in $(cat machines/inventory.txt); do
    ../scripts/check-status.sh $(echo $machine | cut -d: -f2)
done
```

## 📝 Change Log Template

Keep track of changes in `CHANGELOG.md`:

```markdown
## [1.1.0] - 2025-11-11
### Added
- New printer driver support
- Automatic updates script

### Changed
- Updated GNOME to latest
- Improved SSH keepalive settings

### Fixed
- Remmina connection timeout issue
```

---

**Remember:** The workflow is:
1. Edit locally → 2. Commit → 3. Push to GitHub → 4. Deploy from GitHub

This keeps your fleet consistent and traceable! 🎯
