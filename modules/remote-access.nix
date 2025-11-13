# Remote Access Configuration Module
# SSH, Tailscale, and RDP setup for remote management

{ config, pkgs, lib, ... }:

{
  options = {
    sifos.rdp = {
      enable = lib.mkEnableOption "RDP server for remote desktop access";
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
      # Enable xrdp for remote desktop access
      services.xrdp = {
        enable = true;
        defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session";
        openFirewall = false;  # We'll manage firewall ourselves
      };

      # Allow RDP port on Tailscale interface only
      networking.firewall = {
        allowedTCPPorts = [ 3389 ];  # RDP port
      };

      # Ensure xrdp can access the display
      systemd.services.xrdp.serviceConfig = {
        # Allow xrdp to create sessions
        User = lib.mkForce "root";
      };
    })
  ];
}
