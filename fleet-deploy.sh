#!/usr/bin/env bash
# fleet-deploy.sh - Deploy SifOS to multiple machines via Tailscale
# Discovers machines on Tailscale and allows batch deployments

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuration
APPLY_NOW=false
DRY_RUN=false
PARALLEL=false

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Deploy SifOS configuration to one or more machines via Tailscale.

OPTIONS:
    -t TYPE         Deploy to machines of specific type (thin-client, office, workstation, server)
    -m MACHINE      Deploy to specific machine (Tailscale hostname)
    -a              Deploy to all machines
    -l              List available machines and exit
    -y              Apply immediately (default: test only)
    -d              Dry run - show what would be deployed
    -p              Deploy in parallel (use with caution)
    -h              Show this help

EXAMPLES:
    $0 -l                          # List all Tailscale machines
    $0 -m sifos-thin-client-6 -y   # Deploy to one machine
    $0 -t thin-client -y           # Deploy to all thin clients
    $0 -t server -d                # Dry run for all servers
    $0 -a -y                       # Deploy to all machines (careful!)

EOF
    exit 1
}

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_header() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Get list of machines from Tailscale
get_tailscale_machines() {
    # Only get machines that start with "sifos-" to avoid deploying to non-NixOS machines
    tailscale status --json 2>/dev/null | jq -r '.Peer[] | select(.Online == true) | select(.HostName | startswith("sifos-")) | .HostName' | sort
}

# Get machine type from hostname
get_machine_type() {
    local hostname="$1"
    
    # Try to determine type from hostname
    if [[ "$hostname" =~ thin-client ]]; then
        echo "thin-client"
    elif [[ "$hostname" =~ office ]]; then
        echo "office"
    elif [[ "$hostname" =~ workstation ]]; then
        echo "workstation"
    elif [[ "$hostname" =~ server ]]; then
        echo "server"
    elif [[ "$hostname" =~ kiosk ]]; then
        echo "shop-kiosk"
    else
        echo "unknown"
    fi
}

# List all available machines
list_machines() {
    log_header "Tailscale Machines"
    
    local machines=$(get_tailscale_machines)
    
    if [ -z "$machines" ]; then
        log_warning "No online machines found on Tailscale"
        return
    fi
    
    printf "${MAGENTA}%-30s %-20s %-15s${NC}\n" "HOSTNAME" "TYPE" "STATUS"
    echo "────────────────────────────────────────────────────────────────"
    
    while IFS= read -r machine; do
        local type=$(get_machine_type "$machine")
        local status=$(tailscale status --json | jq -r ".Peer[] | select(.HostName == \"$machine\") | if .Online then \"online\" else \"offline\" end")
        
        if [ "$status" = "online" ]; then
            printf "${GREEN}%-30s${NC} %-20s ${GREEN}%-15s${NC}\n" "$machine" "$type" "$status"
        else
            printf "%-30s %-20s ${YELLOW}%-15s${NC}\n" "$machine" "$type" "$status"
        fi
    done <<< "$machines"
}

# Deploy to a single machine
deploy_to_machine() {
    local machine="$1"
    local type="$2"
    local apply_flag=""
    
    if [ "$APPLY_NOW" = true ]; then
        apply_flag="-a"
    fi
    
    log_info "Deploying to $machine (type: $type)..."
    
    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY RUN: Would deploy to $machine with type $type"
        return 0
    fi
    
    # Extract short hostname (remove domain)
    local short_hostname="${machine%%.*}"
    
    # Use the existing remote-deploy.sh script
    if ./remote-deploy.sh -t "$machine" -h "$short_hostname" -m "$type" -y $apply_flag; then
        log_success "Successfully deployed to $machine"
        return 0
    else
        log_error "Failed to deploy to $machine"
        return 1
    fi
}

# Deploy to multiple machines
deploy_to_machines() {
    local machines=("$@")
    local total=${#machines[@]}
    local success=0
    local failed=0
    
    log_header "Deploying to $total machine(s)"
    
    for machine in "${machines[@]}"; do
        local type=$(get_machine_type "$machine")
        
        if [ "$type" = "unknown" ]; then
            log_warning "Skipping $machine - unknown type (please rename with type prefix)"
            ((failed++))
            continue
        fi
        
        if [ "$PARALLEL" = true ]; then
            deploy_to_machine "$machine" "$type" &
        else
            if deploy_to_machine "$machine" "$type"; then
                ((success++))
            else
                ((failed++))
            fi
        fi
    done
    
    if [ "$PARALLEL" = true ]; then
        wait
        log_info "All parallel deployments completed"
    fi
    
    log_header "Deployment Summary"
    log_success "Successful: $success"
    if [ $failed -gt 0 ]; then
        log_error "Failed: $failed"
    fi
}

# Filter machines by type
filter_by_type() {
    local target_type="$1"
    local all_machines=$(get_tailscale_machines)
    local filtered=()
    
    while IFS= read -r machine; do
        local type=$(get_machine_type "$machine")
        if [ "$type" = "$target_type" ]; then
            filtered+=("$machine")
        fi
    done <<< "$all_machines"
    
    echo "${filtered[@]}"
}

# Main logic
DEPLOY_TYPE=""
DEPLOY_MACHINE=""
DEPLOY_ALL=false
LIST_ONLY=false

# Parse arguments
while getopts "t:m:aldyph" opt; do
    case $opt in
        t) DEPLOY_TYPE="$OPTARG" ;;
        m) DEPLOY_MACHINE="$OPTARG" ;;
        a) DEPLOY_ALL=true ;;
        l) LIST_ONLY=true ;;
        y) APPLY_NOW=true ;;
        d) DRY_RUN=true ;;
        p) PARALLEL=true ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Check if tailscale is available
if ! command -v tailscale &> /dev/null; then
    log_error "Tailscale is not installed or not in PATH"
    exit 1
fi

# List machines and exit if requested
if [ "$LIST_ONLY" = true ]; then
    list_machines
    exit 0
fi

# Determine what to deploy
TARGETS=()

if [ -n "$DEPLOY_MACHINE" ]; then
    # Deploy to specific machine
    TARGETS=("$DEPLOY_MACHINE")
elif [ -n "$DEPLOY_TYPE" ]; then
    # Deploy to all machines of a type
    log_info "Finding machines of type: $DEPLOY_TYPE"
    TARGETS=($(filter_by_type "$DEPLOY_TYPE"))
    
    if [ ${#TARGETS[@]} -eq 0 ]; then
        log_error "No online machines found with type: $DEPLOY_TYPE"
        exit 1
    fi
    
    log_info "Found ${#TARGETS[@]} machine(s): ${TARGETS[*]}"
elif [ "$DEPLOY_ALL" = true ]; then
    # Deploy to all machines
    log_warning "Deploying to ALL machines!"
    TARGETS=($(get_tailscale_machines))
    
    if [ ${#TARGETS[@]} -eq 0 ]; then
        log_error "No online machines found"
        exit 1
    fi
    
    if [ "$DRY_RUN" != true ]; then
        read -p "Are you sure you want to deploy to ${#TARGETS[@]} machines? (yes/no): " confirm
        if [ "$confirm" != "yes" ]; then
            log_info "Deployment cancelled"
            exit 0
        fi
    fi
else
    # Interactive mode
    log_header "SifOS Fleet Deployment"
    list_machines
    echo ""
    log_info "Select deployment target:"
    echo "  1) Deploy to one machine"
    echo "  2) Deploy to machine type (thin-client, office, etc.)"
    echo "  3) Deploy to all machines"
    echo "  4) Exit"
    echo ""
    read -p "Choice [1-4]: " choice
    
    case $choice in
        1)
            read -p "Enter machine hostname: " DEPLOY_MACHINE
            TARGETS=("$DEPLOY_MACHINE")
            ;;
        2)
            echo "Available types: thin-client, office, workstation, server, shop-kiosk"
            read -p "Enter machine type: " DEPLOY_TYPE
            TARGETS=($(filter_by_type "$DEPLOY_TYPE"))
            ;;
        3)
            TARGETS=($(get_tailscale_machines))
            read -p "Deploy to ${#TARGETS[@]} machines? (yes/no): " confirm
            if [ "$confirm" != "yes" ]; then
                exit 0
            fi
            ;;
        4)
            exit 0
            ;;
        *)
            log_error "Invalid choice"
            exit 1
            ;;
    esac
    
    read -p "Apply immediately? (yes/no): " apply_confirm
    if [ "$apply_confirm" = "yes" ]; then
        APPLY_NOW=true
    fi
fi

# Execute deployment
if [ ${#TARGETS[@]} -eq 0 ]; then
    log_error "No targets selected"
    exit 1
fi

deploy_to_machines "${TARGETS[@]}"
