#!/usr/bin/env bash
# sync-personal-workstation.sh
# Sync configurations between SifOS and personal nixos-config repository

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

NIXOS_CONFIG_DIR="$HOME/nixos-config"
SIFOS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Check if nixos-config exists
if [ ! -d "$NIXOS_CONFIG_DIR" ]; then
    log_error "nixos-config directory not found at $NIXOS_CONFIG_DIR"
    exit 1
fi

log_header "Personal Workstation Sync Tool"

echo "This script helps sync configurations between:"
echo "  SifOS:       $SIFOS_DIR"
echo "  nixos-config: $NIXOS_CONFIG_DIR"
echo ""
echo "What would you like to do?"
echo "  1) Deploy SifOS config to darren-workstation (manage via fleet)"
echo "  2) Copy shell config from nixos-config to SifOS"
echo "  3) Copy package list from darren-workstation to SifOS workstation type"
echo "  4) Show differences between configurations"
echo "  5) Exit"
echo ""
read -p "Choice [1-5]: " choice

case $choice in
    1)
        log_header "Deploy SifOS to Personal Workstation"
        log_info "This will apply the SifOS darren-workstation machine type"
        
        if [ ! -f "$SIFOS_DIR/machine-types/darren-workstation.nix" ]; then
            log_error "darren-workstation.nix not found in SifOS"
            exit 1
        fi
        
        # Check if we're on the right machine
        if [ "$(hostname)" != "darren-workstation" ]; then
            log_warning "Current hostname is $(hostname), not darren-workstation"
            read -p "Continue anyway? (yes/no): " confirm
            if [ "$confirm" != "yes" ]; then
                exit 0
            fi
        fi
        
        # Deploy locally
        log_info "Deploying SifOS configuration..."
        cd "$SIFOS_DIR"
        
        # Update machine-config.nix to use darren-workstation type
        if [ -f machine-config.nix ]; then
            sed -i 's|./machine-types/.*\.nix|./machine-types/darren-workstation.nix|' machine-config.nix
        fi
        
        log_info "Testing configuration..."
        if sudo nixos-rebuild test; then
            log_success "Test successful!"
            read -p "Apply permanently? (yes/no): " apply
            if [ "$apply" = "yes" ]; then
                sudo nixos-rebuild switch
                log_success "Configuration applied!"
            fi
        else
            log_error "Test failed - configuration not applied"
        fi
        ;;
        
    2)
        log_header "Sync Shell Config"
        
        # Check for zsh config in nixos-config
        if [ -f "$NIXOS_CONFIG_DIR/modules/system/shell.nix" ]; then
            log_info "Found shell.nix in nixos-config"
            echo ""
            echo "Personal config:"
            head -20 "$NIXOS_CONFIG_DIR/modules/system/shell.nix"
            echo ""
            echo "SifOS config:"
            head -20 "$SIFOS_DIR/modules/shell.nix"
            echo ""
            log_warning "Manual review recommended - configs use different structures"
        else
            log_info "No shell.nix found in nixos-config"
        fi
        ;;
        
    3)
        log_header "Compare Package Lists"
        
        log_info "Packages in nixos-config darren-workstation:"
        grep -r "environment.systemPackages" "$NIXOS_CONFIG_DIR/hosts/darren-workstation/" || true
        grep -r "environment.systemPackages" "$NIXOS_CONFIG_DIR/hosts/common/" | head -20 || true
        
        echo ""
        log_info "Packages in SifOS workstation:"
        grep "environment.systemPackages" "$SIFOS_DIR/machine-types/darren-workstation.nix" || true
        ;;
        
    4)
        log_header "Show Configuration Differences"
        
        log_info "SifOS uses traditional configuration.nix structure"
        log_info "nixos-config uses flakes with modular profiles"
        echo ""
        echo "Key differences:"
        echo "  - nixos-config: Flake-based, home-manager, COSMIC desktop support"
        echo "  - SifOS: Traditional, fleet management, Tailscale integration"
        echo ""
        echo "Recommendation: Keep them separate OR integrate flakes into SifOS"
        ;;
        
    5)
        exit 0
        ;;
        
    *)
        log_error "Invalid choice"
        exit 1
        ;;
esac
