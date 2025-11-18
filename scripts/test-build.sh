#!/usr/bin/env bash
# Flake-native smoke checks for SifOS
# - nix flake check
# - build thin-client system derivation

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}SifOS Flake Smoke Checks${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo -e "${CYAN}Running: nix flake check${NC}"
nix flake check --option experimental-features "nix-command flakes"
echo -e "${GREEN}✓ flake check passed${NC}"

echo ""
echo -e "${CYAN}Building thin-client system derivation${NC}"
nix build .#nixosConfigurations.thin-client-6.config.system.build.toplevel --option experimental-features "nix-command flakes"
echo -e "${GREEN}✓ thin-client build succeeded${NC}"

echo ""
echo -e "${GREEN}✓ All smoke checks passed${NC}"
