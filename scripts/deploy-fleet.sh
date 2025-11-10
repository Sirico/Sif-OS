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
MACHINE_TYPE=""

usage() {
    echo "Usage: $0 [-a] [-p] [-m <machine-type>] [-f <inventory-file>]"
    echo "  -a: Apply immediately (default: test only)"
    echo "  -p: Deploy in parallel (faster but harder to debug)"
    echo "  -m: Machine type for all machines (default: prompt per machine)"
    echo "  -f: Inventory file (default: machines/inventory.txt)"
    echo ""
    echo "Inventory file format (one per line):"
    echo "  hostname:ip:type:description"
    echo "Example:"
    echo "  dispatch-01:192.168.0.49:thin-client:Office A"
    echo "  office-pc-1:192.168.0.50:office:Main Office"
    echo ""
    echo "If type is omitted in inventory, uses -m option or prompts"
    exit 1
}

# Parse arguments
while getopts "apm:f:" opt; do
    case $opt in
        a) APPLY=true ;;
        p) PARALLEL=true ;;
        m) MACHINE_TYPE="$OPTARG" ;;
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
    local type=$(echo "$line" | cut -d: -f3)
    local desc=$(echo "$line" | cut -d: -f4)
    
    # Use machine type from inventory, command line, or default
    if [ -z "$type" ] || [ "$type" = "$desc" ]; then
        type="${MACHINE_TYPE:-thin-client}"
    fi
    
    echo -e "${YELLOW}[$hostname]${NC} Deploying to $ip ($desc) as $type..."
    
    local args="-t $ip -h $hostname -m $type -y"
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
