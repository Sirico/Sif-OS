# Quick Setup Guide

## First Time Setup

### 1. Add Your SSH Key

Edit `modules/users.nix` and add your SSH public key:

```bash
# Get your public key
cat ~/.ssh/id_ed25519.pub

# Or generate one if you don't have it
ssh-keygen -t ed25519 -C "admin@sifos"
```

Add the key to the `admin` user in `modules/users.nix`:

```nix
openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... admin@your-machine"
];
```

### 2. Change Default Passwords

Edit `modules/users.nix` and change:
```nix
initialPassword = "changeme";  # Set a strong password
```

### 3. Test on First Machine

On your test Wyse 5070:

```bash
# Install NixOS if not already done
# Follow: https://nixos.org/manual/nixos/stable/#sec-installation

# Generate hardware config
sudo nixos-generate-config

# Deploy SifOS config from your workstation
cd /home/darren/sif-os
./deploy.sh -h test-01 -t 192.168.0.49

# SSH to the machine
ssh admin@192.168.0.49

# Apply the configuration
sudo nixos-rebuild switch

# Connect to Tailscale (first time)
sudo tailscale up

# Reboot
sudo reboot
```

### 4. After Reboot

The machine should:
- Auto-login as `sif` user
- Display GNOME desktop
- Have Remmina available
- Be accessible via SSH and Tailscale

### 5. Configure Remmina

As the `sif` user:
1. Open Remmina
2. Add a new connection
3. Protocol: RDP
4. Server: `<proxmox-vm-ip>:3389`
5. Username: `<windows-username>`
6. Password: `<windows-password>`
7. Save the connection

The connection file is saved in `~/.local/share/remmina/`

### 6. Set Up Printing

```bash
# Open printer settings
system-config-printer

# Add your label printer
# Follow the printer-specific setup
```

### 7. Verify Everything Works

- [ ] Can RDP to Windows VM
- [ ] Can print to label printer
- [ ] Can SSH from your workstation
- [ ] Can access via Tailscale
- [ ] Auto-login works after reboot

## Deploy to Additional Machines

```bash
# From your workstation
./deploy.sh -h dispatch-02 -t <target-ip>

# Then SSH and apply
ssh admin@<target-ip>
sudo nixos-rebuild switch
sudo tailscale up
```

## Common Commands

```bash
# Rebuild configuration
sudo nixos-rebuild switch

# Test without applying
sudo nixos-rebuild test

# Rollback to previous version
sudo nixos-rebuild switch --rollback

# Check Tailscale status
sudo tailscale status

# View system logs
journalctl -xe

# Check SSH service
sudo systemctl status sshd

# Check CUPS (printing)
sudo systemctl status cups
```

## Troubleshooting

### Can't SSH
```bash
# Check SSH is running
sudo systemctl status sshd
sudo systemctl start sshd

# Check firewall
sudo iptables -L -n
```

### Tailscale not working
```bash
# Check service
sudo systemctl status tailscale

# Reconnect
sudo tailscale down
sudo tailscale up
```

### Remmina connection fails
- Verify Windows VM is running
- Check network connectivity: `ping <vm-ip>`
- Verify RDP is enabled on Windows VM
- Check firewall rules on Windows VM

### Printer not found
```bash
# Check CUPS
sudo systemctl status cups

# List printers
lpstat -p -d

# Check printer queue
lpq

# Restart CUPS
sudo systemctl restart cups
```
