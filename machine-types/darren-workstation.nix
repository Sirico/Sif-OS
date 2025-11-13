# Darren's Personal Workstation Configuration
# This machine type syncs with ~/nixos-config/hosts/darren-workstation
# Allows managing your personal workstation through the SifOS fleet

{ config, pkgs, lib, ... }:

{
  imports = [
    ../modules/shell.nix
  ];

  # Full GNOME Desktop (matching your personal config)
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # Sound with PipeWire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Development packages - full stack
  environment.systemPackages = with pkgs; [
    # Development Tools
    vscode
    git
    gitg
    docker
    docker-compose
    podman
    
    # Programming languages
    python3
    python311Packages.pip
    python311Packages.virtualenv
    nodejs_22
    nodePackages.npm
    nodePackages.yarn
    rustc
    cargo
    go
    jdk17
    gcc
    clang
    
    # Build tools
    gnumake
    cmake
    pkg-config
    
    # Browsers
    firefox
    chromium
    
    # Office tools
    libreoffice-fresh
    
    # System tools
    vim
    neovim
    wget
    curl
    htop
    btop
    ncdu
    tree
    ripgrep
    fd
    fzf
    
    # Network tools
    networkmanagerapplet
    wireshark
    nmap
    
    # Terminal
    gnome-console
    tmux
    
    # Remote access
    remmina
    # teamviewer  # May not be available in nixpkgs 25.05
    
    # Database tools (uncomment if needed)
    # postgresql
    # mysql-workbench
    
    # Monitoring (uncomment if needed)
    # prometheus
    # grafana
  ];

  # Enable Docker and Podman
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };
  
  # Podman (don't use dockerCompat when docker is enabled)
  virtualisation.podman = {
    enable = true;
  };

  # Add admin to docker group
  users.users.admin.extraGroups = [ "docker" ];

  # NO auto-login for workstation
  services.displayManager.autoLogin.enable = lib.mkForce false;

  # No automatic updates - developer controls updates
  system.autoUpgrade = {
    enable = false;
    allowReboot = false;
  };

  # Normal power management
  # Workstation can sleep when idle
}
