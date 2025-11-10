#!/usr/bin/env bash
# deploy.sh - Deploy SifOS configuration to a thin client

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REMOTE_USER="admin"
REMOTE_HOST=""
HOSTNAME=""

usage() {
    echo "Usage: $0 -h <hostname> -t <target-ip> [-u <user>]"
    echo "  -h: Hostname for the thin client (e.g., dispatch-01)"
    echo "  -t: Target IP address or hostname"
    echo "  -u: Remote user (default: admin)"
    exit 1
}

# Parse arguments
while getopts "h:t:u:" opt; do
    case $opt in
        h) HOSTNAME="$OPTARG" ;;
        t) REMOTE_HOST="$OPTARG" ;;
        u) REMOTE_USER="$OPTARG" ;;
        *) usage ;;
    esac
done

if [ -z "$HOSTNAME" ] || [ -z "$REMOTE_HOST" ]; then
    usage
fi

echo -e "${GREEN}SifOS Deployment Script${NC}"
echo "Target: $REMOTE_USER@$REMOTE_HOST"
echo "Hostname: $HOSTNAME"
echo ""

# Create temporary configuration
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo -e "${YELLOW}Preparing configuration...${NC}"

# Copy base configuration
cp -r configuration.nix modules/ "$TEMP_DIR/"

# Update hostname in temporary configuration
sed -i "s/networking.hostName = \".*\"/networking.hostName = \"sifos-$HOSTNAME\"/" "$TEMP_DIR/configuration.nix"

echo -e "${YELLOW}Deploying to $REMOTE_HOST...${NC}"

# Copy configuration to target
scp -o ServerAliveInterval=60 -r "$TEMP_DIR"/* "$REMOTE_USER@$REMOTE_HOST:/tmp/sifos-config/"

# Apply configuration
echo -e "${YELLOW}Applying configuration on remote machine...${NC}"
ssh -o ServerAliveInterval=60 "$REMOTE_USER@$REMOTE_HOST" << 'EOF'
    set -e
    
    # Backup existing configuration
    sudo cp -r /etc/nixos /etc/nixos.backup.$(date +%Y%m%d-%H%M%S) 2>/dev/null || true
    
    # Copy new configuration
    sudo cp -r /tmp/sifos-config/* /etc/nixos/
    
    # Keep the existing hardware-configuration.nix
    sudo cp /etc/nixos.backup.*/hardware-configuration.nix /etc/nixos/nixos/ 2>/dev/null || true
    
    # Clean up
    rm -rf /tmp/sifos-config
    
    # Test configuration
    echo "Testing configuration..."
    sudo nixos-rebuild test
    
    echo ""
    echo "Configuration test successful!"
    echo "To apply permanently, run: sudo nixos-rebuild switch"
EOF

echo ""
echo -e "${GREEN}Deployment complete!${NC}"
echo ""
echo "Next steps:"
echo "1. SSH to the machine: ssh $REMOTE_USER@$REMOTE_HOST"
echo "2. Apply the configuration: sudo nixos-rebuild switch"
echo "3. Connect to Tailscale (first time): sudo tailscale up"
echo "4. Reboot if needed: sudo reboot"
