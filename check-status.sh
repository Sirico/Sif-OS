#!/usr/bin/env bash
# check-status.sh - Check the status of deployed SifOS thin clients

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
    echo "Usage: $0 <hostname-or-ip> [hostname-or-ip...]"
    echo "  Check status of one or more thin clients"
    echo ""
    echo "Example:"
    echo "  $0 192.168.0.49"
    echo "  $0 dispatch-01 dispatch-02"
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

check_host() {
    local HOST=$1
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Checking: $HOST${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Check if reachable
    if ! ping -c 1 -W 2 "$HOST" &>/dev/null; then
        echo -e "${RED}✗ Host unreachable${NC}"
        return 1
    fi
    echo -e "${GREEN}✓ Host reachable${NC}"
    
    # Check SSH
    if ! ssh -o ConnectTimeout=5 -o BatchMode=yes "admin@$HOST" "echo ok" &>/dev/null; then
        echo -e "${RED}✗ SSH connection failed${NC}"
        return 1
    fi
    echo -e "${GREEN}✓ SSH connection OK${NC}"
    
    # Get system info
    echo ""
    echo -e "${YELLOW}System Information:${NC}"
    
    ssh "admin@$HOST" bash << 'EOF'
        echo "Hostname: $(hostname)"
        echo "NixOS Version: $(nixos-version)"
        echo "Uptime: $(uptime -p)"
        echo "Kernel: $(uname -r)"
        echo ""
        echo "Users logged in:"
        who || echo "  (none)"
        echo ""
        echo "Tailscale Status:"
        if systemctl is-active --quiet tailscale; then
            TAILSCALE_IP=$(sudo tailscale ip -4 2>/dev/null || echo "Not connected")
            echo "  Service: Running"
            echo "  IP: $TAILSCALE_IP"
        else
            echo "  Service: Not running"
        fi
        echo ""
        echo "Disk Usage:"
        df -h / | tail -1 | awk '{print "  Root: " $3 "/" $2 " (" $5 ")"}'
        echo ""
        echo "Memory Usage:"
        free -h | grep Mem: | awk '{print "  Used: " $3 "/" $2}'
        echo ""
        echo "Services:"
        for service in sshd tailscale cups gdm; do
            if systemctl is-active --quiet $service; then
                echo "  ✓ $service"
            else
                echo "  ✗ $service"
            fi
        done
EOF
    
    echo ""
}

# Check each host
for HOST in "$@"; do
    check_host "$HOST"
    echo ""
done

echo -e "${GREEN}Status check complete!${NC}"
