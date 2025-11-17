# Thin Client Configuration Module
# Minimal desktop for RDP/dispatch stations

{ config, pkgs, ... }:

{
  nix.settings.require-sigs = false;

  imports = [
    ../modules/citizen-da210-cups-filter-pkg.nix
  ];

  # Enable RDP server for remote access to this thin client
  sifos.rdp.enable = true;

  # X11 and Desktop Environment
  services.xserver = {
    enable = true;
    
    # GNOME Desktop (lightweight alternative: xfce)
    displayManager.gdm = {
      enable = true;
      wayland = false;  # Disable Wayland for better xrdp compatibility
    };
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

  # Essential thin client packages
  environment.systemPackages = with pkgs; [
    # RDP Client
    remmina
    
    # Utilities
    firefox
    vim
    wget
    curl
    htop
    git  # Needed for self-update (admin only)
    
    # Network tools
    networkmanagerapplet
    
    # File manager
    gnome-console
    nautilus
  ];

  # Exclude unnecessary GNOME packages to save space
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-software
    epiphany      # web browser (we use firefox)
    geary         # email client
    gnome-music
    gnome-photos
    gnome-maps
    cheese        # webcam tool
    totem         # video player
  ];

  # Auto-login to sif user for thin client operation
  services.displayManager.autoLogin = {
    enable = true;
    user = "sif";
  };

  # Workaround for GNOME autologin
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Auto-start Remmina on login for the sif user
  systemd.user.services.remmina-autostart = {
    description = "Auto-start Remmina RDP client";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.remmina}/bin/remmina";
      Restart = "no";
    };
  };

  # Enable the service for the sif user
  systemd.user.services.remmina-autostart.enable = true;

  # Enable automatic updates (optional - can be disabled for stability)
  system.autoUpgrade = {
    enable = false;  # Set to true if you want automatic updates
    allowReboot = false;
  };

  # Disable sleep/suspend for thin clients
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
}
