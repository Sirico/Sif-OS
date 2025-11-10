#!/usr/bin/env bash
# remote-deploy.sh - Deploy SifOS from GitHub to remote thin clients
# This script pulls the latest configuration from GitHub and deploys it

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
REPO_URL="https://github.com/Sirico/sif-os.git"
BRANCH="main"
REMOTE_USER="admin"
REMOTE_HOST=""
HOSTNAME=""
APPLY_NOW=false

usage() {
    echo "Usage: $0 -t <target-ip> -h <hostname> [-u <user>] [-a]"
    echo "  -t: Target IP address or hostname"
    echo "  -h: Hostname for the thin client (e.g., dispatch-01)"
    echo "  -u: Remote user (default: admin)"
    echo "  -a: Apply immediately (default: test only)"
    echo ""
    echo "Example:"
    echo "  $0 -t 192.168.0.49 -h dispatch-01"
    echo "  $0 -t 192.168.0.49 -h dispatch-01 -a  # Apply immediately"
    exit 1
}

# Parse arguments
while getopts "t:h:u:a" opt; do
    case $opt in
        t) REMOTE_HOST="$OPTARG" ;;
        h) HOSTNAME="$OPTARG" ;;
        u) REMOTE_USER="$OPTARG" ;;
        a) APPLY_NOW=true ;;
        *) usage ;;
    esac
done

if [ -z "$HOSTNAME" ] || [ -z "$REMOTE_HOST" ]; then
    usage
fi

echo -e "${GREEN}SifOS Remote Deployment from GitHub${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Repository: $REPO_URL"
echo "Branch: $BRANCH"
echo "Target: $REMOTE_USER@$REMOTE_HOST"
echo "Hostname: $HOSTNAME"
echo "Mode: $([ "$APPLY_NOW" = true ] && echo "Apply immediately" || echo "Test only")"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check connectivity
echo -e "${YELLOW}Checking connectivity...${NC}"
if ! ping -c 1 -W 2 "$REMOTE_HOST" &>/dev/null; then
    echo -e "${RED}✗ Cannot reach $REMOTE_HOST${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Host reachable${NC}"

# Deploy via SSH
echo -e "${YELLOW}Deploying configuration from GitHub...${NC}"

ssh -o ServerAliveInterval=60 "$REMOTE_USER@$REMOTE_HOST" bash << EOF
    set -e
    
    echo "Cloning/updating repository..."
    
    # Clone or update the repository
    if [ -d /tmp/sifos-deploy/.git ]; then
        cd /tmp/sifos-deploy
        git fetch origin
        git reset --hard origin/$BRANCH
        echo "✓ Repository updated"
    else
        rm -rf /tmp/sifos-deploy
        git clone -b $BRANCH $REPO_URL /tmp/sifos-deploy
        echo "✓ Repository cloned"
    fi
    
    cd /tmp/sifos-deploy
    
    # Update hostname in configuration
    sed -i 's/networking.hostName = ".*"/networking.hostName = "sifos-$HOSTNAME"/' configuration.nix
    
    # Backup existing configuration
    sudo cp -r /etc/nixos /etc/nixos.backup.\$(date +%Y%m%d-%H%M%S) 2>/dev/null || true
    
    # Copy new configuration (preserve existing hardware-configuration.nix)
    echo "Copying configuration to /etc/nixos..."
    sudo mkdir -p /etc/nixos/modules /etc/nixos/machines
    sudo cp configuration.nix /etc/nixos/
    sudo cp -r modules/* /etc/nixos/modules/
    sudo cp -r machines/* /etc/nixos/machines/ 2>/dev/null || true
    
    # Keep the existing hardware configuration
    if [ ! -f /etc/nixos/nixos/hardware-configuration.nix ]; then
        sudo mkdir -p /etc/nixos/nixos
        if [ -f /etc/nixos/hardware-configuration.nix ]; then
            sudo cp /etc/nixos/hardware-configuration.nix /etc/nixos/nixos/
        else
            echo "Generating hardware configuration..."
            sudo nixos-generate-config --dir /tmp/hw-config
            sudo cp /tmp/hw-config/hardware-configuration.nix /etc/nixos/nixos/
        fi
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Configuration deployed successfully!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if [ "$APPLY_NOW" = "true" ]; then
        echo "Applying configuration..."
        sudo nixos-rebuild switch
        echo ""
        echo "✓ Configuration applied!"
        echo ""
        echo "Next steps:"
        echo "  - Connect to Tailscale: sudo tailscale up"
        echo "  - Reboot if needed: sudo reboot"
    else
        echo "Testing configuration..."
        sudo nixos-rebuild test
        echo ""
        echo "✓ Configuration test successful!"
        echo ""
        echo "To apply permanently, run:"
        echo "  sudo nixos-rebuild switch"
        echo ""
        echo "Or re-run this script with -a flag"
    fi
EOF

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Deployment complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
