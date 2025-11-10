#!/usr/bin/env bash
# test-config.sh - Test the SifOS configuration before applying

echo "SifOS Configuration Test"
echo "========================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo:"
    echo "  sudo bash $0"
    exit 1
fi

CONFIG_DIR="/tmp/sifos-test"

if [ ! -f "$CONFIG_DIR/configuration.nix" ]; then
    echo "Error: Configuration not found at $CONFIG_DIR"
    echo "Please copy configuration files first"
    exit 1
fi

echo "Step 1: Checking configuration syntax..."
cd "$CONFIG_DIR"
if nixos-rebuild dry-build -I nixos-config=./configuration.nix; then
    echo "✓ Configuration syntax is valid!"
else
    echo "✗ Configuration has errors"
    exit 1
fi

echo ""
echo "Step 2: Building configuration (test mode)..."
if nixos-rebuild test -I nixos-config=./configuration.nix; then
    echo "✓ Configuration builds and can be activated!"
else
    echo "✗ Configuration build failed"
    exit 1
fi

echo ""
echo "========================================="
echo "✓ All tests passed!"
echo "========================================="
echo ""
echo "The configuration is ready to deploy."
echo ""
echo "To apply permanently:"
echo "  1. sudo cp -r $CONFIG_DIR/* /etc/nixos/"
echo "  2. sudo nixos-rebuild switch"
echo ""
echo "Or to test first without making permanent:"
echo "  sudo nixos-rebuild test"
