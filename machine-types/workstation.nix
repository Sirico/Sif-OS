# Workstation Configuration Module
# Development and power user configuration

{ config, pkgs, ... }:

{
  # X11 and Desktop Environment
  services.xserver = {
    enable = true;
    
    # Full GNOME Desktop
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

  # Development and power user packages
  environment.systemPackages = with pkgs; [
    # Development Tools
    vscode
    git
    gitg  # Git GUI
    docker
    docker-compose
    
    # Programming languages (add as needed)
    python3
    nodejs
    
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
    
    # Network tools
    networkmanagerapplet
    wireshark
    nmap
    
    # Terminal
    gnome-console
    tmux
    
    # File management
    nautilus
    
    # Remote access
    remmina
  ];

  # Minimal GNOME exclusions (keep more tools)
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-software
    epiphany
  ];

  # Enable Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Add users to docker group (in users.nix)
  # users.users.admin.extraGroups = [ "docker" ];

  # Multi-user setup - NO auto-login
  # Developers login with their own accounts

  # No automatic updates (developers control updates)
  system.autoUpgrade = {
    enable = false;
    allowReboot = false;
  };

  # Normal power management
  # Workstations can sleep when idle
}
