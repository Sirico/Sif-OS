#!/usr/bin/env bash
# self-update.sh - Run this ON the thin client to update from GitHub
# This script should be installed on each thin client

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO_URL="https://github.com/Sirico/sif-os.git"
BRANCH="main"
APPLY=false

usage() {
    echo "Usage: sudo $0 [-a]"
    echo "  -a: Apply immediately (default: test only)"
    echo ""
    echo "This script updates the SifOS configuration from GitHub"
    exit 1
}

# Parse arguments
while getopts "a" opt; do
    case $opt in
        a) APPLY=true ;;
        *) usage ;;
    esac
done

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root: sudo $0${NC}"
    exit 1
fi

echo -e "${GREEN}SifOS Self-Update${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get current hostname to preserve it
CURRENT_HOSTNAME=$(hostname)
echo "Current hostname: $CURRENT_HOSTNAME"
echo ""

# Clone or update repository
echo -e "${YELLOW}Fetching latest configuration from GitHub...${NC}"

if [ -d /tmp/sifos-update/.git ]; then
    cd /tmp/sifos-update
    git fetch origin
    git reset --hard origin/$BRANCH
    echo -e "${GREEN}✓ Repository updated${NC}"
else
    rm -rf /tmp/sifos-update
    git clone -b $BRANCH $REPO_URL /tmp/sifos-update
    echo -e "${GREEN}✓ Repository cloned${NC}"
fi

cd /tmp/sifos-update

# Preserve hostname in machine-config.nix
sed -i "s/networking.hostName = \".*\"/networking.hostName = \"$CURRENT_HOSTNAME\"/" machine-config.nix

# Backup existing configuration
BACKUP_DIR="/etc/nixos.backup.$(date +%Y%m%d-%H%M%S)"
echo -e "${YELLOW}Backing up current configuration to $BACKUP_DIR...${NC}"
cp -r /etc/nixos "$BACKUP_DIR"
echo -e "${GREEN}✓ Backup created${NC}"

# Copy new configuration (preserve hardware-configuration.nix)
echo -e "${YELLOW}Installing new configuration...${NC}"
cp configuration.nix machine-config.nix /etc/nixos/
cp -r modules/* /etc/nixos/modules/
cp -r machines/* /etc/nixos/machines/ 2>/dev/null || true
cp -r remmina-profiles/* /etc/nixos/remmina-profiles/ 2>/dev/null || true
cp -r remmina-profiles/* /etc/sifos/remmina-profiles/ 2>/dev/null || true

echo -e "${GREEN}✓ Configuration installed${NC}"
echo ""

# Test or apply
if [ "$APPLY" = true ]; then
    echo -e "${YELLOW}Applying configuration...${NC}"
    nixos-rebuild switch
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✓ Update complete and applied!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
else
    echo -e "${YELLOW}Testing configuration...${NC}"
    nixos-rebuild test
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✓ Configuration test successful!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "To apply permanently:"
    echo "  sudo nixos-rebuild switch"
    echo ""
    echo "Or run: sudo $0 -a"
    echo ""
    echo "To rollback if needed:"
    echo "  sudo nixos-rebuild switch --rollback"
    echo "  or restore from: $BACKUP_DIR"
fi

# Cleanup
rm -rf /tmp/sifos-update
