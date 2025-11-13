# Remote Access Configuration Module
# SSH, Tailscale, and RDP setup for remote management

{ config, pkgs, lib, ... }:

{
  options = {
    sifos.rdp = {
      enable = lib.mkEnableOption "RDP server for remote desktop access";
    };
    
    sifos.tailscale = {
      advertiseAddress = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Tailscale IP address for this machine (for documentation)";
        example = "100.78.103.61";
      };
    };
  };

  config = lib.mkMerge [
    # Always enabled: SSH and Tailscale
    {
  # OpenSSH Server
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;  # Can disable after SSH keys are deployed
      PermitRootLogin = "no";
      X11Forwarding = true;
    };
    # Keep connections alive
    extraConfig = ''
      ClientAliveInterval 60
      ClientAliveCountMax 10
    '';
  };

  # Tailscale VPN
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # Firewall configuration
  networking.firewall = {
    enable = true;
    # Allow SSH
    allowedTCPPorts = [ 22 ];
    # Trust Tailscale interface
    trustedInterfaces = [ "tailscale0" ];
    # Allow Tailscale
    checkReversePath = "loose";
  };

  # System packages for remote access
  environment.systemPackages = with pkgs; [
    tailscale
  ];

  # Enable automatic reconnection of Tailscale
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      # Wait for tailscale to be ready
      sleep 2
      # Check if already connected
      status="$(${pkgs.tailscale}/bin/tailscale status -json 2>/dev/null || echo '{}')"
      if echo "$status" | ${pkgs.jq}/bin/jq -e '.BackendState == "Running"' > /dev/null; then
        echo "Tailscale already connected"
      else
        echo "Tailscale not connected. Please run 'tailscale up' manually first time."
      fi
    '';
  };

  # Keep SSH sessions alive
  programs.ssh.extraConfig = ''
    ServerAliveInterval 60
    ServerAliveCountMax 10
  '';
    }

    
    # Optional: RDP server
    (lib.mkIf config.sifos.rdp.enable {
      # Use xrdp for RDP access with GNOME
      services.xrdp = {
        enable = true;
        defaultWindowManager = "gnome-session";
        openFirewall = false;  # We manage firewall ourselves
      };

      # Allow RDP port
      networking.firewall = {
        allowedTCPPorts = [ 3389 ];  # RDP port
      };
      
      # Create .xsession for GNOME RDP sessions
      environment.etc."xrdp/startwm.sh" = {
        text = ''
          #!/bin/sh
          if [ -r /etc/profile ]; then
            . /etc/profile
          fi
          
          if [ -r ~/.profile ]; then
            . ~/.profile
          fi
          
          # Start GNOME session
          exec ${pkgs.gnome-session}/bin/gnome-session
        '';
        mode = "0755";
      };
    })
    
    # Display Tailscale connection info
    (lib.mkIf (config.sifos.tailscale.advertiseAddress != null) {
      environment.etc."issue".text = lib.mkAfter ''
        
        Tailscale IP: ${config.sifos.tailscale.advertiseAddress}
        RDP Access: ${config.sifos.tailscale.advertiseAddress}:3389
      '';
      
      # Show on SSH login
      programs.bash.interactiveShellInit = lib.mkAfter ''
        if [ -n "$SSH_CONNECTION" ]; then
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          echo "Tailscale IP: ${config.sifos.tailscale.advertiseAddress}"
          echo "RDP Access: ${config.sifos.tailscale.advertiseAddress}:3389"
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        fi
      '';
    })
  ];
}
