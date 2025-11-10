# Remmina RDP Connection Profiles

This directory contains pre-configured Remmina RDP connection profiles that will be deployed to all thin clients.

## How It Works

1. Profiles are stored here in `.remmina` format
2. During deployment, they're copied to `/etc/sifos/remmina-profiles/` on each machine
3. On first login, the `sif` user automatically gets these profiles copied to `~/.local/share/remmina/`
4. Users can then connect immediately without manual configuration

## Configuring a Profile

### Edit the Template

The main template is `windows-vm.remmina`. Edit this file to configure:

**Required Settings:**
- `name=` - Connection name shown in Remmina
- `server=` - Windows VM IP and port (e.g., `192.168.1.100:3389`)

**Optional Settings:**
- `username=` - Windows login username (leave empty for prompt)
- `password=` - Leave empty (users will enter)
- `resolution_width=` - Screen width (default: 1920)
- `resolution_height=` - Screen height (default: 1080)
- `printer=1` - Enable printer redirection (1=yes, 0=no)

### Example Configuration

For a Windows VM at `192.168.1.100`:

```ini
[remmina]
name=Dispatch VM - Main
protocol=RDP
server=192.168.1.100:3389
username=dispatcher
domain=
```

## Creating Multiple Profiles

You can create multiple profiles for different VMs:

```bash
# Copy template
cp windows-vm.remmina dispatch-vm-1.remmina

# Edit for specific VM
vim dispatch-vm-1.remmina
```

**Common scenarios:**

**Dispatch VM 1:**
```ini
name=Dispatch VM 1
server=192.168.1.100:3389
```

**Dispatch VM 2:**
```ini
name=Dispatch VM 2
server=192.168.1.101:3389
```

**Warehouse VM:**
```ini
name=Warehouse System
server=192.168.1.102:3389
```

## Deployment

After editing profiles:

1. **Commit changes:**
   ```bash
   git add remmina-profiles/
   git commit -m "Update Remmina profiles for dispatch VMs"
   git push
   ```

2. **Deploy to machines:**
   ```bash
   ./remote-deploy.sh -t 192.168.0.49 -h thin-client-1 -a
   ```

3. **Users get profiles automatically** on next login

## Testing

Test a profile manually:

```bash
# On the thin client as sif user
remmina -c ~/.local/share/remmina/windows-vm.remmina
```

## Security Notes

⚠️ **Do NOT store passwords in profiles!**

- Leave `password=` empty
- Users will be prompted to enter passwords
- Remmina can save passwords securely per-user if needed

## Profile Format Reference

Common Remmina RDP settings:

```ini
[remmina]
name=                      # Connection name
protocol=RDP              # Always RDP for Windows
server=IP:PORT            # VM address and port
username=                 # Windows username (optional)
password=                 # Leave empty!
domain=                   # Windows domain (if any)
resolution_mode=1         # 0=use initial, 1=custom, 2=fullscreen
resolution_width=1920     # Screen width
resolution_height=1080    # Screen height
color_depth=32            # 8, 16, or 32 bits
printer=1                 # Printer redirection (0/1)
sound=local               # Audio: local, off, remote
cert_ignore=1             # Ignore certificate warnings (0/1)
scale=1                   # Scale display to fit (0/1)
window_maximize=1         # Start maximized (0/1)
viewmode=1                # 1=scrolled, 2=fullscreen, 3=viewport
```

## Troubleshooting

### Profile Not Showing Up

Check if profile was deployed:
```bash
ls -la /etc/sifos/remmina-profiles/
ls -la ~/.local/share/remmina/
```

### Force Re-deployment

As `sif` user:
```bash
/etc/sifos/setup-remmina.sh
```

### Connection Fails

- Verify VM IP address: `ping 192.168.1.100`
- Check VM is running in Proxmox
- Verify RDP is enabled on Windows VM
- Check Windows Firewall settings
- Test with manual connection first

## Pro Tips

1. **Name profiles clearly** - Use location/purpose in name
2. **Test before deploying** - Try on one machine first
3. **Document VM mappings** - Keep list of which VM is which
4. **Use consistent ports** - Stick to 3389 unless needed
5. **Enable printer redirection** - Usually needed for dispatch

## Example: Complete Setup

```bash
# 1. Edit profile for your environment
vim remmina-profiles/windows-vm.remmina
# Change: server=192.168.1.100:3389
# Change: name=Dispatch Main VM

# 2. Commit and push
git add remmina-profiles/
git commit -m "Configure RDP for dispatch VM at 192.168.1.100"
git push

# 3. Deploy to all machines
./deploy-fleet.sh -a

# 4. Users login and profiles are ready!
```
