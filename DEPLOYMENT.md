# SifOS Deployment Checklist

## Pre-Deployment

- [ ] Add your SSH public key to `modules/users.nix`
- [ ] Change default password for sif user in `modules/users.nix`
- [ ] Test configuration on a single Wyse 5070
- [ ] Document Proxmox VM connection details
- [ ] Identify label printer models and ensure drivers are in `modules/printing.nix`

## Per-Machine Deployment

For each thin client:

- [ ] Record MAC address and serial number
- [ ] Choose a hostname (e.g., dispatch-01, dispatch-02)
- [ ] Note physical location
- [ ] Install NixOS (if not already installed)
- [ ] Run hardware detection: `nixos-generate-config`
- [ ] Deploy configuration: `./deploy.sh -h <hostname> -t <ip>`
- [ ] SSH to machine and apply: `sudo nixos-rebuild switch`
- [ ] Connect to Tailscale: `sudo tailscale up`
- [ ] Set user passwords
- [ ] Configure Remmina with Proxmox VM connections
- [ ] Test RDP connection to Windows VM
- [ ] Set up label printer
- [ ] Test printing
- [ ] Document in inventory

## Post-Deployment

- [ ] Create inventory spreadsheet with all deployed machines
- [ ] Set up monitoring (optional)
- [ ] Document common troubleshooting procedures
- [ ] Train users on basic operations
- [ ] Set up backup/restore procedure for Remmina configurations

## Maintenance

- [ ] Schedule regular updates (monthly?)
- [ ] Monitor Tailscale connectivity
- [ ] Check for NixOS security updates
- [ ] Review logs for issues
- [ ] Update documentation as needed

## Notes

- Wyse 5070 specs to verify:
  - RAM: 4GB minimum, 8GB recommended
  - Storage: 16GB minimum for NixOS
  - Network: Ethernet preferred over WiFi for stability
  
- Network requirements:
  - DHCP or static IP
  - Access to Proxmox network
  - Outbound internet for Tailscale
  - Access to printer network/subnet
