# Work Context Switcher Module
# Easily switch between SIF and PEI work environments

{ config, pkgs, lib, ... }:

{
  options.workContextSwitcher = {
    enable = lib.mkEnableOption "Work context switching scripts";
  };

  config = lib.mkIf config.workContextSwitcher.enable {
    environment.systemPackages = with pkgs; [
      # Switch to SIF work context
      (pkgs.writeScriptBin "work-sif" ''
        #!${pkgs.bash}/bin/bash
        echo "🏢 Switching to SIF context..."
        
        # Logout of current Tailscale
        echo "  → Logging out of Tailscale..."
        sudo ${pkgs.tailscale}/bin/tailscale logout 2>/dev/null || true
        
        # Login to SIF Tailscale
        echo "  → Connecting to SIF network..."
        sudo ${pkgs.tailscale}/bin/tailscale up
        
        # Show connection status
        echo ""
        echo "✓ Connected to SIF network"
        ${pkgs.tailscale}/bin/tailscale status | head -5
        
        echo ""
        echo "📧 Open Outlook and select SIF profile"
        echo "🌐 You can now access SIF resources via Tailscale"
        
        # Notify user
        ${pkgs.libnotify}/bin/notify-send "Work Context" "Switched to SIF" -i network-vpn
      '')
      
      # Switch to PEI work context
      (pkgs.writeScriptBin "work-pei" ''
        #!${pkgs.bash}/bin/bash
        echo "🏢 Switching to PEI context..."
        
        # Logout of current Tailscale
        echo "  → Logging out of Tailscale..."
        sudo ${pkgs.tailscale}/bin/tailscale logout 2>/dev/null || true
        
        # Login to PEI Tailscale
        echo "  → Connecting to PEI network..."
        sudo ${pkgs.tailscale}/bin/tailscale up
        
        # Show connection status
        echo ""
        echo "✓ Connected to PEI network"
        ${pkgs.tailscale}/bin/tailscale status | head -5
        
        echo ""
        echo "📧 Open Outlook and select PEI profile"
        echo "🌐 You can now access PEI resources via Tailscale"
        
        # Notify user
        ${pkgs.libnotify}/bin/notify-send "Work Context" "Switched to PEI" -i network-vpn
      '')
      
      # Switch to personal/home context (disconnect from work VPNs)
      (pkgs.writeScriptBin "work-off" ''
        #!${pkgs.bash}/bin/bash
        echo "🏠 Switching to personal context..."
        
        # Logout of work Tailscale
        echo "  → Disconnecting from work networks..."
        sudo ${pkgs.tailscale}/bin/tailscale logout 2>/dev/null || true
        
        echo ""
        echo "✓ Disconnected from work networks"
        echo "🏠 You are now in personal mode"
        
        # Notify user
        ${pkgs.libnotify}/bin/notify-send "Work Context" "Switched to Personal" -i user-home
      '')
      
      # Check current work context
      (pkgs.writeScriptBin "work-status" ''
        #!${pkgs.bash}/bin/bash
        echo "🔍 Current Work Context Status"
        echo "================================"
        echo ""
        
        # Check Tailscale status
        if sudo ${pkgs.tailscale}/bin/tailscale status &>/dev/null; then
          echo "📡 Tailscale Status:"
          sudo ${pkgs.tailscale}/bin/tailscale status | head -10
          echo ""
          
          # Try to determine which network
          HOSTNAME=$(sudo ${pkgs.tailscale}/bin/tailscale status --json | ${pkgs.jq}/bin/jq -r '.Self.HostName' 2>/dev/null || echo "unknown")
          
          if [[ "$HOSTNAME" == *"sif"* ]] || [[ "$HOSTNAME" == *"SIF"* ]]; then
            echo "🏢 Context: SIF"
          elif [[ "$HOSTNAME" == *"pei"* ]] || [[ "$HOSTNAME" == *"PEI"* ]]; then
            echo "🏢 Context: PEI"
          else
            echo "🔍 Context: Unknown (check Tailscale admin)"
          fi
        else
          echo "🏠 Not connected to work network (Personal mode)"
        fi
      '')
    ];
    
    # Add helpful aliases
    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
      sif = "work-sif";
      pei = "work-pei";
      personal = "work-off";
      ws = "work-status";
    };
    
    programs.bash.shellAliases = {
      sif = "work-sif";
      pei = "work-pei";
      personal = "work-off";
      ws = "work-status";
    };
  };
}
