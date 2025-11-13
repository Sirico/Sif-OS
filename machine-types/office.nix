# Office Configuration Module
# Full desktop environment for office productivity

{ config, pkgs, ... }:

{
  imports = [
    ../modules/shell.nix
  ];

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

  # Office productivity packages
  environment.systemPackages = with pkgs; [
    # Office Suite
    libreoffice-fresh
    
    # Communication
    firefox
    thunderbird
    
    # PDF and documents
    evince  # PDF viewer
    
    # Utilities
    vim
    wget
    curl
    htop
    git
    
    # Network tools
    networkmanagerapplet
    
    # File manager and desktop
    gnome-console
    nautilus
    
    # Optional: Remote access
    # remmina  # Uncomment if needed
  ];

  # Keep useful GNOME apps for office use
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-software
    epiphany      # we use firefox
    gnome-music   # optional media apps
    cheese        # webcam tool
  ];

  # Multi-user setup - NO auto-login for office
  # Users login with their own accounts

  # Enable automatic updates (can be adjusted)
  system.autoUpgrade = {
    enable = false;
    allowReboot = false;
  };

  # Normal power management (sleep/suspend enabled)
  # Office machines can sleep when idle
}
