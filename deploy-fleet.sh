#!/usr/bin/env bash
# deploy-fleet.sh - Deploy to multiple machines from inventory

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

INVENTORY_FILE="machines/inventory.txt"
APPLY=false
PARALLEL=false

usage() {
    echo "Usage: $0 [-a] [-p] [-f <inventory-file>]"
    echo "  -a: Apply immediately (default: test only)"
    echo "  -p: Deploy in parallel (faster but harder to debug)"
    echo "  -f: Inventory file (default: machines/inventory.txt)"
    echo ""
    echo "Inventory file format (one per line):"
    echo "  hostname:ip:description"
    echo "Example:"
    echo "  dispatch-01:192.168.0.49:Office A"
    echo "  dispatch-02:192.168.0.50:Office B"
    exit 1
}

# Parse arguments
while getopts "apf:" opt; do
    case $opt in
        a) APPLY=true ;;
        p) PARALLEL=true ;;
        f) INVENTORY_FILE="$OPTARG" ;;
        *) usage ;;
    esac
done

if [ ! -f "$INVENTORY_FILE" ]; then
    echo -e "${RED}Error: Inventory file not found: $INVENTORY_FILE${NC}"
    echo ""
    echo "Create an inventory file with format:"
    echo "  hostname:ip:description"
    exit 1
fi

echo -e "${GREEN}SifOS Fleet Deployment${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Inventory: $INVENTORY_FILE"
echo "Mode: $([ "$APPLY" = true ] && echo "Apply" || echo "Test only")"
echo "Parallel: $([ "$PARALLEL" = true ] && echo "Yes" || echo "No")"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Read inventory
mapfile -t MACHINES < "$INVENTORY_FILE"

if [ ${#MACHINES[@]} -eq 0 ]; then
    echo -e "${RED}No machines in inventory${NC}"
    exit 1
fi

echo "Found ${#MACHINES[@]} machine(s) in inventory"
echo ""

# Function to deploy to one machine
deploy_one() {
    local line=$1
    local hostname=$(echo "$line" | cut -d: -f1)
    local ip=$(echo "$line" | cut -d: -f2)
    local desc=$(echo "$line" | cut -d: -f3)
    
    echo -e "${YELLOW}[$hostname]${NC} Deploying to $ip ($desc)..."
    
    local args="-t $ip -h $hostname"
    [ "$APPLY" = true ] && args="$args -a"
    
    if ./remote-deploy.sh $args 2>&1 | sed "s/^/[$hostname] /"; then
        echo -e "${GREEN}[$hostname] ✓ Success${NC}"
        return 0
    else
        echo -e "${RED}[$hostname] ✗ Failed${NC}"
        return 1
    fi
}

# Deploy to all machines
SUCCESS=0
FAILED=0

if [ "$PARALLEL" = true ]; then
    echo "Deploying in parallel..."
    echo ""
    
    for machine in "${MACHINES[@]}"; do
        deploy_one "$machine" &
    done
    
    wait
else
    for machine in "${MACHINES[@]}"; do
        if deploy_one "$machine"; then
            ((SUCCESS++))
        else
            ((FAILED++))
        fi
        echo ""
    done
fi

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Deployment Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Total machines: ${#MACHINES[@]}"
echo -e "${GREEN}Successful: $SUCCESS${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $FAILED -gt 0 ]; then
    exit 1
fi
