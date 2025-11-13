# Work PWA Setup - SIF and PEI Simultaneous Access

Run Outlook and Teams for both SIF and PEI companies **at the same time** using Progressive Web Apps (PWAs).

## Overview

Each company gets its own isolated Outlook and Teams application:
- **SIF Outlook** - Separate login, separate profile
- **SIF Teams** - Separate login, separate profile  
- **PEI Outlook** - Separate login, separate profile
- **PEI Teams** - Separate login, separate profile

All four apps run simultaneously, each with independent logins and data.

## Launch Commands

### Launch Everything
```bash
work-launch-all
```
Launches all four apps (SIF + PEI Outlook and Teams)

### Launch by Company
```bash
work-launch-sif   # Just SIF Outlook + Teams
work-launch-pei   # Just PEI Outlook + Teams
```

### Launch Individual Apps
```bash
sif-outlook    # SIF Outlook only
sif-teams      # SIF Teams only
pei-outlook    # PEI Outlook only
pei-teams      # PEI Teams only
```

## First Time Setup

1. **Launch all apps:**
   ```bash
   work-launch-all
   ```

2. **Sign in to each app** with the appropriate company account:
   - Open **SIF Outlook** → Sign in with your SIF Microsoft account
   - Open **SIF Teams** → Sign in with your SIF Microsoft account
   - Open **PEI Outlook** → Sign in with your PEI Microsoft account
   - Open **PEI Teams** → Sign in with your PEI Microsoft account

3. **Stay signed in** - Each app maintains its own session independently

## Daily Workflow

### Option 1: Auto-start at Login
Add to your desktop environment's autostart:
```bash
work-launch-all
```

### Option 2: Manual Launch
Run when you start your work day:
```bash
work-launch-all
```

## How It Works

Each PWA uses a **separate browser profile** (`--user-data-dir`):
- `~/.config/sif-outlook-pwa/` - SIF Outlook data
- `~/.config/sif-teams-pwa/` - SIF Teams data
- `~/.config/pei-outlook-pwa/` - PEI Outlook data
- `~/.config/pei-teams-pwa/` - PEI Teams data

This means:
- ✅ Separate logins for each company
- ✅ No cross-contamination of data
- ✅ All four apps can run at the same time
- ✅ Independent cookies, cache, settings
- ✅ Each app appears as separate window in taskbar

## Desktop Entries

PWAs also appear in your application menu:
- Search for "SIF Outlook", "SIF Teams", "PEI Outlook", "PEI Teams"
- Pin them to your taskbar/dock for quick access
- Each has its own window class for workspace management

## Tailscale Network Access

Since you can only be connected to **one Tailscale network** at a time:

**Recommended approach:**
- Connect Tailscale to whichever network (SIF or PEI) you need internal resource access for
- Outlook and Teams work via web without Tailscale (public Microsoft 365)
- Switch Tailscale networks when you need to access internal servers

**Alternative approach:**
- Keep Tailscale connected to your most-used network
- Use VPN or other access method for the other company's internal resources

## Browser Choice

Configure which browser to use in `darren-workstation.nix`:

```nix
workPWA = {
  enable = true;
  browser = "chromium";  # Options: "chromium", "brave", "google-chrome", "microsoft-edge"
};
```

**Recommended:** Chromium or Brave (fully open source and in nixpkgs)

## Troubleshooting

### Apps won't stay signed in
- Check that cookies are enabled in the browser
- Make sure `~/.config/*-pwa/` directories have correct permissions

### Notifications not working  
- Grant notification permissions when prompted
- Check desktop environment notification settings

### Apps look different/old version
- Clear the PWA cache: `rm -rf ~/.config/sif-outlook-pwa/` (you'll need to sign in again)
- Microsoft updates web apps regularly, refresh to get latest

### Want to reset an app completely
```bash
rm -rf ~/.config/sif-outlook-pwa/   # Reset SIF Outlook
rm -rf ~/.config/pei-teams-pwa/     # Reset PEI Teams
# etc...
```

## Installation

This module is included in `darren-workstation` machine type.

To enable on your personal workstation:
```bash
cd ~/nixos-config
# Add to your configuration:
# imports = [ /home/darren/sif-os/modules/work-pwa.nix ];
# workPWA.enable = true;
```
