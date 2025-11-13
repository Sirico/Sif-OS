#!/usr/bin/env bash
# test-build.sh - Test SifOS configurations locally before pushing to GitHub
# This script validates all machine types can build successfully

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}SifOS Configuration Test Suite${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
cd "$REPO_DIR"

# Create temporary test directory
TEST_DIR=$(mktemp -d)
echo -e "${YELLOW}Test directory: $TEST_DIR${NC}"
echo ""

# Function to test a machine type
test_machine_type() {
    local type=$1
    local import_line=$2
    
    echo -e "${CYAN}Testing machine type: $type${NC}"
    
    # Copy configuration files to test directory
    cp -r . "$TEST_DIR/"
    cd "$TEST_DIR"
    
    # Update machine-config.nix to import the specific type
    if [ "$type" != "custom" ]; then
        sed -i "s|./machine-types/.*\.nix|$import_line|" machine-config.nix
    else
        # For custom, comment out the import
        sed -i 's|.*./machine-types/.*\.nix|    # ./machine-types/thin-client.nix|' machine-config.nix
    fi
    
    # Try to build the configuration
    echo -n "  Building... "
    if nix-instantiate --eval -E "(import <nixpkgs/nixos> { configuration = ./configuration.nix; }).config.system.build.toplevel.drvPath" &>/dev/null; then
        echo -e "${GREEN}✓ PASS${NC}"
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        echo -e "${RED}Error details:${NC}"
        nix-instantiate --eval -E "(import <nixpkgs/nixos> { configuration = ./configuration.nix; }).config.system.build.toplevel.drvPath" 2>&1 | head -20
        return 1
    fi
}

# Test each machine type
TYPES=(
    "thin-client:./machine-types/thin-client.nix"
    "office:./machine-types/office.nix"
    "workstation:./machine-types/workstation.nix"
    "darren-workstation:./machine-types/darren-workstation.nix"
    "shop-kiosk:./machine-types/shop-kiosk.nix"
    "server:./machine-types/server.nix"
    "custom:none"
)

FAILED=0
PASSED=0

for type_config in "${TYPES[@]}"; do
    IFS=':' read -r type import <<< "$type_config"
    
    if test_machine_type "$type" "$import"; then
        ((PASSED++)) || true
    else
        ((FAILED++)) || true
    fi
    
    # Clean up test directory for next test
    cd "$REPO_DIR"
    rm -rf "$TEST_DIR" || true
    TEST_DIR=$(mktemp -d) || true
    
    echo ""
done

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Test Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo ""

# Cleanup
rm -rf "$TEST_DIR"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed! Safe to push to GitHub.${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed. Fix errors before pushing.${NC}"
    exit 1
fi
