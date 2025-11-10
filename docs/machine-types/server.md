# Server Machine Type

**Purpose:** Local server for hosting web applications, containers, and services for the office.

**Target Hardware:** Dell OptiPlex 5070 or similar server-class hardware

## Features

### Container Management
- **Podman** - Container runtime with Docker compatibility
- **Podman Compose** - Docker Compose alternative
- **Buildah & Skopeo** - Container image tools
- **Podman TUI** - Terminal UI for container management

### Web Management
- **Cockpit** - Web-based server administration (port 9090)
  - Access: `http://<server-ip>:9090` or via Tailscale
  - System monitoring, service management, container management
  - Log viewing and system updates

### Web Services
- **Nginx** - Reverse proxy and web server
  - Pre-configured with recommended settings
  - Ready for hosting web applications
  - Ports 80 (HTTP) and 443 (HTTPS) open

### Monitoring & Tools
- **Prometheus Node Exporter** - System metrics (port 9100)
- **System Monitoring Tools:** htop, btop, iotop, nethogs, ncdu
- **Network Tools:** curl, wget, nmap, tcpdump
- **Database Clients:** PostgreSQL, MariaDB

### Security Features
- **SSH Key-Only Authentication** - No password login
- **Firewall Enabled** - Only essential ports open
- **Tailscale Integration** - Secure remote access
- **Automatic Security Updates** - Daily update checks

### Performance Tuning
- Optimized file descriptor limits (2M file-max)
- Network performance tuning
- Memory management (low swappiness)
- Automatic log rotation
- Weekly garbage collection

## Default Configuration

### Network Ports
- **22** - SSH (Tailscale or local network)
- **80** - HTTP (web applications)
- **443** - HTTPS (web applications)
- **9090** - Cockpit web interface
- **9100** - Prometheus metrics (internal)

### Services
- SSH server (key-based auth only)
- Tailscale VPN client
- Cockpit web admin
- Nginx web server
- Podman container runtime

### System Behavior
- **No Desktop Environment** - Headless server
- **No Auto-Login** - SSH access required
- **No Screen Blanking** - Server runs 24/7
- **Automatic Updates** - Daily, no auto-reboot

## Usage

### Accessing the Server

1. **Via Tailscale:**
   ```bash
   ssh admin@<tailscale-hostname>
   ```

2. **Via Local Network:**
   ```bash
   ssh admin@<local-ip>
   ```

3. **Via Cockpit Web Interface:**
   - Open browser: `http://<server-ip>:9090`
   - Login with admin credentials

### Managing Containers

```bash
# List running containers
podman ps

# Pull and run a container
podman run -d -p 8080:80 nginx

# Use podman-compose
podman-compose up -d

# View container logs
podman logs <container-id>

# Access Podman TUI
podman-tui
```

### Managing Services

```bash
# Check service status
systemctl status nginx
systemctl status cockpit

# Restart a service
sudo systemctl restart nginx

# View logs
journalctl -u nginx -f
```

### Web Application Hosting

1. **Using Nginx directly:**
   - Edit `/etc/nginx/nginx.conf`
   - Add your site configuration
   - Restart nginx: `sudo systemctl restart nginx`

2. **Using containers:**
   ```bash
   # Run containerized web app
   podman run -d -p 8080:80 --name myapp <image>
   
   # Configure Nginx reverse proxy
   # Add proxy_pass to nginx config
   ```

### System Monitoring

1. **Via Cockpit:**
   - Navigate to `http://<server-ip>:9090`
   - View CPU, memory, disk, network usage
   - Manage services and containers

2. **Via CLI:**
   ```bash
   # System resources
   htop
   btop
   
   # Disk usage
   ncdu /
   
   # Network activity
   nethogs
   
   # IO activity
   sudo iotop
   ```

## Deployment

### Initial Setup

1. Create machine-config.nix:
```nix
{ config, pkgs, ... }:

{
  networking.hostName = "sifos-server-1";
  
  imports = [
    ./machine-types/server.nix
  ];
}
```

2. Deploy from GitHub:
```bash
./remote-deploy.sh -t <server-ip> -h sifos-server-1 -m server
```

3. Connect to Tailscale:
```bash
ssh admin@<server-ip>
sudo tailscale up
```

### Regular Maintenance

- **Updates:** Automatic daily (manual reboot required)
- **Garbage Collection:** Automatic weekly
- **Container Pruning:** Automatic weekly
- **Logs:** Retained for 1 month, max 2GB

## Security Notes

- SSH password authentication is **disabled** by default
- Only admin user can SSH (must have authorized_keys configured)
- Cockpit allows unencrypted access (use Tailscale for encryption)
- All inbound traffic should go through Tailscale except HTTP/HTTPS
- No desktop environment = minimal attack surface

## Troubleshooting

### Can't SSH into server
- Check SSH key is in admin's authorized_keys
- Verify firewall: `sudo systemctl status firewall`
- Check SSH service: `sudo systemctl status sshd`

### Can't access Cockpit
- Check service: `sudo systemctl status cockpit.socket`
- Verify port 9090 is open: `sudo ss -tlnp | grep 9090`

### Container issues
- Check Podman: `podman version`
- View logs: `journalctl -u podman`
- Clean up: `podman system prune`

### Performance issues
- Check resources: `htop` or Cockpit
- View logs: `journalctl -p err -b`
- Check disk space: `df -h`

## Next Steps

After deployment:
1. Configure Nginx for your web applications
2. Deploy containers with Podman
3. Set up reverse proxy rules
4. Configure SSL/TLS certificates (Let's Encrypt)
5. Set up backups (restic/rclone included)
6. Monitor via Cockpit or Prometheus
