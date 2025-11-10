# Next Steps - Getting SifOS Ready for Deployment

## 🎯 Immediate Actions Required

### 1. Add Your SSH Public Key (CRITICAL)

**Why**: This allows you to SSH to machines without passwords

**How**:
```bash
# View your public key
cat ~/.ssh/id_ed25519.pub

# If you don't have one, create it
ssh-keygen -t ed25519 -C "admin@sifos"
```

**Where**: Edit `modules/users.nix` at line ~17:
```nix
openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... YOUR-KEY-HERE"
];
```

### 2. Change Default Password (CRITICAL)

**Why**: Security - the default password "changeme" is obviously not secure

**Where**: Edit `modules/users.nix` at line ~42:
```nix
initialPassword = "YourSecurePasswordHere";
```

### 3. Test on Your Current Machine (192.168.0.49)

**Run**:
```bash
cd /home/darren/sif-os
./deploy.sh -h test-01 -t 192.168.0.49
```

**Then SSH and apply**:
```bash
ssh admin@192.168.0.49
sudo nixos-rebuild switch
sudo tailscale up
sudo reboot
```

## ✅ Validation Checklist

After deployment, verify:

- [ ] Machine auto-boots to sif user desktop
- [ ] Can SSH as admin: `ssh admin@192.168.0.49`
- [ ] Tailscale is connected: `ssh admin@192.168.0.49 'sudo tailscale status'`
- [ ] Remmina is installed: Launch from applications menu
- [ ] Can configure RDP connection in Remmina
- [ ] CUPS is running: `ssh admin@192.168.0.49 'systemctl status cups'`
- [ ] No sleep/suspend: Machine stays on continuously

## 📋 Before Rolling Out to Production

1. **Document your Proxmox VMs**
   - List all Windows VMs that dispatchers connect to
   - Note IP addresses and RDP ports
   - Document any special connection requirements

2. **Test label printers**
   - Identify exact printer models
   - Test printing from test machine
   - May need to add specific drivers to `modules/printing.nix`

3. **Create inventory tracking**
   - Spreadsheet with: hostname, IP, MAC address, location, serial number
   - Track which machine is deployed where

4. **Plan rollout schedule**
   - Start with one or two machines
   - Let users test for a few days
   - Gather feedback before full deployment

## 🔧 Optional Customizations

### Lighter Desktop Environment

If GNOME is too heavy, switch to XFCE in `modules/thin-client.nix`:

```nix
# Replace these lines:
services.xserver.displayManager.gdm.enable = true;
services.xserver.desktopManager.gnome.enable = true;

# With:
services.xserver.displayManager.lightdm.enable = true;
services.xserver.desktopManager.xfce.enable = true;
```

### Static IP Addresses

For machines that need fixed IPs, create per-machine configs in `machines/`:

```bash
cp machines/template.nix machines/dispatch-01.nix
```

Edit and uncomment the networking section.

### Pre-configured Remmina Connections

You can deploy Remmina connection files to all machines:

1. Create a connection on test machine
2. Copy from `~/.local/share/remmina/` 
3. Deploy to other machines (requires custom module)

### Add More Admin Tools

Edit `modules/users.nix` to add tools for the admin user:

```nix
packages = with pkgs; [
  vim
  htop
  tmux
  git
  tcpdump    # Network debugging
  nmap       # Network scanning
  # Add more as needed
];
```

## 📚 Documentation Files Reference

- **PROJECT-SUMMARY.md** - Overview of entire project
- **README.md** - Complete documentation with all features
- **QUICKSTART.md** - Fast setup guide for quick reference
- **DEPLOYMENT.md** - Detailed deployment checklist
- **NEXT-STEPS.md** - This file!

## 🚀 Deployment Commands Quick Reference

```bash
# Deploy to a new machine
./deploy.sh -h <hostname> -t <ip-address>

# Check status of deployed machines
./check-status.sh 192.168.0.49

# SSH to a machine
ssh admin@<ip-or-hostname>

# Apply configuration changes
sudo nixos-rebuild switch

# Test without applying
sudo nixos-rebuild test

# Rollback if something breaks
sudo nixos-rebuild switch --rollback

# Check Tailscale
sudo tailscale status
sudo tailscale ip

# Check services
systemctl status sshd
systemctl status tailscale
systemctl status cups
systemctl status gdm
```

## 🐛 If Something Goes Wrong

### Can't SSH after deployment
```bash
# From the physical machine or via console
sudo systemctl start sshd
sudo systemctl enable sshd
```

### Configuration doesn't apply
```bash
# Check for syntax errors
sudo nixos-rebuild test

# View detailed errors
sudo nixos-rebuild switch --show-trace
```

### Need to start over
```bash
# Rollback to previous configuration
sudo nixos-rebuild switch --rollback

# Or restore from backup
sudo cp -r /etc/nixos.backup.YYYYMMDD-HHMMSS/* /etc/nixos/
```

## 💡 Tips

- Always test configuration changes on one machine first
- Keep notes on each machine deployment
- Use Tailscale names for easier access: `ssh admin@sifos-test-01.your-tailnet.ts.net`
- Set up SSH config on your workstation for easier access:

```bash
# Add to ~/.ssh/config
Host sifos-*
    User admin
    ServerAliveInterval 60
    ServerAliveCountMax 10
```

## 🎓 Learning More

- NixOS Manual: https://nixos.org/manual/nixos/stable/
- NixOS Options: https://search.nixos.org/options
- Remmina Documentation: https://remmina.org/
- Tailscale Docs: https://tailscale.com/kb/

---

**Ready to start?**

1. Add SSH key to `modules/users.nix`
2. Change password in `modules/users.nix`
3. Run `./deploy.sh -h test-01 -t 192.168.0.49`

Good luck! 🚀
