# Server Machine Type Configuration
# For local server hosting (OptiPlex 5070)
# Provides web app hosting, container management, and administration tools
#
# Features:
# - Cockpit web management interface (port 9090)
# - Podman for containerized applications
# - Docker compatibility layer
# - Nginx reverse proxy
# - Server monitoring tools
# - No desktop environment (headless by default)
# - SSH access required
# - Tailscale for secure remote access

{ config, pkgs, lib, ... }:

{
  # Server doesn't need desktop environment
  services.xserver.enable = lib.mkForce false;
  services.desktopManager.plasma6.enable = lib.mkForce false;
  services.displayManager.autoLogin.enable = lib.mkForce false;
  
  # Disable branding module (no GUI)
  disabledModules = [ ../modules/branding.nix ];

  # Cockpit web-based server management
  services.cockpit = {
    enable = true;
    port = 9090;
    settings = {
      WebService = {
        AllowUnencrypted = true;  # Use Tailscale for encryption
      };
    };
  };

  # Podman for container management
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;  # Docker compatibility
    defaultNetwork.settings.dns_enabled = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # Docker socket for compatibility
  virtualisation.containers.enable = true;
  
  # Nginx reverse proxy
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
  };

  # Server packages
  environment.systemPackages = with pkgs; [
    # Container tools
    podman-compose
    podman-tui
    buildah
    skopeo
    
    # Web server tools
    nginx
    
    # Monitoring and management
    htop
    btop
    iotop
    nethogs
    ncdu
    
    # Network tools
    curl
    wget
    netcat
    nmap
    tcpdump
    
    # System tools
    vim
    git
    tmux
    screen
    rsync
    
    # Database clients
    postgresql
    mariadb-client
    
    # Development tools
    nodejs
    python3
    
    # Backup tools
    restic
    rclone
  ];

  # Enable container image building
  virtualisation.containers.storage.settings = {
    storage = {
      driver = "overlay2";
      runroot = "/run/containers/storage";
      graphroot = "/var/lib/containers/storage";
    };
  };

  # Firewall configuration for server
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 
      80    # HTTP
      443   # HTTPS
      9090  # Cockpit
    ];
    # Tailscale manages its own firewall rules
    trustedInterfaces = [ "tailscale0" ];
  };

  # Override SSH settings for server security (key-based auth only)
  services.openssh.settings = {
    PasswordAuthentication = lib.mkForce false;
    KbdInteractiveAuthentication = lib.mkForce false;
  };

  # System monitoring
  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9100;
      };
    };
  };

  # Automatic updates for security
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;  # Manual reboot for servers
    dates = "daily";
    flags = [ "--update-input" "nixpkgs" ];
  };

  # Server-specific services
  services.logrotate.enable = true;
  
  # Enable automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Performance tuning for server
  boot.kernel.sysctl = {
    # Increase file descriptor limits
    "fs.file-max" = 2097152;
    "fs.nr_open" = 1048576;
    
    # Network performance
    "net.core.somaxconn" = 32768;
    "net.ipv4.tcp_max_syn_backlog" = 8192;
    "net.core.netdev_max_backlog" = 5000;
    
    # Memory management
    "vm.swappiness" = 10;
  };

  # Set resource limits
  systemd.extraConfig = ''
    DefaultLimitNOFILE=65536
  '';

  # Journal configuration for server logs
  services.journald.extraConfig = ''
    SystemMaxUse=2G
    MaxRetentionSec=1month
  '';
}
