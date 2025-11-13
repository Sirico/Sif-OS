# Work Context Switching

Quick commands to switch between SIF and PEI work environments on your personal workstation.

## Commands

### Switch to SIF Work
```bash
work-sif   # or just: sif
```
- Disconnects from current Tailscale network
- Connects to SIF Tailscale network
- Shows desktop notification
- Reminds you to open SIF Outlook profile

### Switch to PEI Work
```bash
work-pei   # or just: pei
```
- Disconnects from current Tailscale network
- Connects to PEI Tailscale network
- Shows desktop notification
- Reminds you to open PEI Outlook profile

### Switch to Personal Mode
```bash
work-off   # or just: personal
```
- Disconnects from all work networks
- Returns to personal/home mode

### Check Current Context
```bash
work-status   # or just: ws
```
- Shows which work network you're connected to
- Displays Tailscale connection status

## Workflow Examples

### Starting SIF Work Day
```bash
$ sif
🏢 Switching to SIF context...
  → Logging out of Tailscale...
  → Connecting to SIF network...

✓ Connected to SIF network
📧 Open Outlook and select SIF profile
🌐 You can now access SIF resources via Tailscale
```

### Switching Between Companies
```bash
# Finish SIF work, switch to PEI
$ pei

# Done with work, back to personal
$ personal
```

### Check What You're Connected To
```bash
$ ws
🔍 Current Work Context Status
================================

📡 Tailscale Status:
100.78.103.61   sifos-thin-client-6  ...
🏢 Context: SIF
```

## Outlook Profile Switching

You'll still need to manually switch Outlook profiles when changing contexts:

1. Open Outlook
2. File → Office Account → Switch Profile
3. Select SIF or PEI profile

**Tip:** Keep Outlook closed when switching contexts, then open it fresh in the new context.

## Security Notes

- Each context uses a separate Tailscale network
- No cross-contamination between SIF and PEI
- Personal mode disconnects from all work networks
- Desktop notifications keep you aware of current context

## Installation

This module is already included in `darren-workstation` machine type. 

To enable on your personal workstation:
```bash
cd ~/nixos-config
# Add to your configuration:
# imports = [ /home/darren/sif-os/modules/work-context-switcher.nix ];
# workContextSwitcher.enable = true;
```
