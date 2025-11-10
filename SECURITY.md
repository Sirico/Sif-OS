# Security Model

## User Access Levels

### Admin User (you)
- **Can**: Full system access via sudo
- **Can**: Update system configuration
- **Can**: Run update scripts (`/etc/sifos/self-update.sh`)
- **Can**: SSH into the system
- **Can**: Install packages system-wide
- **Cannot**: Login via GUI (console/SSH only)

### Sif User (standard user)
- **Can**: Use Remmina to connect to Windows VMs
- **Can**: Print to label printers
- **Can**: Use Firefox and installed applications
- **Can**: Access their home directory
- **Cannot**: Run sudo commands
- **Cannot**: Modify system configuration
- **Cannot**: Access `/etc/sifos/` scripts
- **Cannot**: Install system packages
- **Cannot**: SSH from outside (no SSH keys)

## File Permissions

### Admin-Only Files
These require root/sudo access:

```
/etc/sifos/self-update.sh        (mode: 0700, owner: root)
/etc/nixos/                      (system configuration)
```

### User-Accessible Files
Standard users can access:

```
~/.local/share/remmina/          (RDP connection profiles)
~/Documents, ~/Downloads, etc.   (user home directory)
```

## Network Security

### Firewall Rules
- **SSH (port 22)**: Allowed from any IP
- **Tailscale**: Full access via VPN
- **All other incoming**: Blocked by default

### SSH Access
- **admin user**: SSH key authentication only (password optional)
- **sif user**: No SSH access (not in SSH allowed users)

### Tailscale Access
- Both local network and Tailscale can access SSH
- Tailscale provides secure remote access when machines are offsite

## Update Security

### How Updates Work
1. Admin makes changes on workstation
2. Changes pushed to GitHub (version controlled)
3. Updates deployed from GitHub (not arbitrary scripts)
4. All updates require sudo (admin only)

### Update Methods (All Admin-Only)

**Remote Update (from workstation)**:
```bash
./remote-deploy.sh -t <machine> -h <hostname>
# Requires: SSH access as admin
```

**Self-Update (on machine)**:
```bash
sudo /etc/sifos/self-update.sh
# Requires: sudo privileges (admin only)
```

**Fleet Update (multiple machines)**:
```bash
./deploy-fleet.sh
# Requires: SSH access to all machines as admin
```

## Physical Security Considerations

### Auto-Login
- **Risk**: Anyone with physical access can use the machine as "sif" user
- **Mitigation**: Limited privileges, no sudo access
- **Use Case**: Appropriate for thin clients in controlled environments (dispatch stations)

### Disable Auto-Login (if needed)
Edit `modules/users.nix` and remove:
```nix
services.displayManager.autoLogin = {
  enable = true;
  user = "sif";
};
```

## Application Security

### Remmina Connections
- Connection profiles stored in user's home directory
- Each user has separate profiles
- Windows VM credentials stored in Remmina (encrypted)

### Firefox
- Standard user restrictions apply
- No access to system files
- Cannot install system-wide extensions

### Printing
- Users can print to configured printers
- Cannot modify printer configuration
- Cannot add new printers (requires admin)

## Monitoring & Audit

### What's Logged
- SSH connections: `/var/log/auth.log`
- System changes: NixOS generations
- Sudo usage: `/var/log/sudo.log`

### Checking Logs (Admin Only)
```bash
# Recent SSH logins
sudo journalctl -u sshd | tail -50

# Sudo usage
sudo cat /var/log/sudo.log

# System changes
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

## Best Practices

### For Admins
1. ✅ Use SSH keys, not passwords
2. ✅ Keep GitHub repository private
3. ✅ Test updates on one machine first
4. ✅ Review logs periodically
5. ✅ Use Tailscale for remote access
6. ❌ Don't share admin password with users
7. ❌ Don't commit secrets to Git

### For Deployment
1. ✅ Change default passwords immediately
2. ✅ Add SSH keys to admin user
3. ✅ Configure Tailscale on each machine
4. ✅ Document each machine's location
5. ✅ Keep inventory updated
6. ❌ Don't deploy untested configurations
7. ❌ Don't skip backups

## Hardening Options (Optional)

### Disable Password Authentication
In `modules/remote-access.nix`:
```nix
services.openssh.settings.PasswordAuthentication = false;
```

### Restrict SSH to Tailscale Only
In `modules/remote-access.nix`:
```nix
services.openssh.listenAddresses = [
  { addr = "100.64.0.0/10"; }  # Tailscale subnet
];
```

### Require Password for Sudo
In `modules/users.nix`, remove the NOPASSWD sudo rule for admin.

### Enable Fail2ban
Add to `modules/remote-access.nix`:
```nix
services.fail2ban = {
  enable = true;
  ignoreIP = [ "100.64.0.0/10" ];  # Don't ban Tailscale
};
```

## Incident Response

### Compromised Machine
1. Disconnect from network
2. Check logs: `sudo journalctl -xe`
3. Review recent changes: `git log`
4. Rollback: `sudo nixos-rebuild switch --rollback`
5. Investigate source of compromise
6. Re-deploy clean configuration

### Lost/Stolen Machine
1. Remove from Tailscale network
2. Revoke SSH keys if applicable
3. Change Windows VM passwords if stored in Remmina
4. Document incident

### Unauthorized Changes
1. Check who made changes: `sudo last`
2. Review sudo logs: `sudo cat /var/log/sudo.log`
3. Rollback to previous generation
4. Change admin password

---

**Remember**: The sif user is intentionally limited. All system management requires admin access with sudo.
