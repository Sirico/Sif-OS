# Shop Kiosk Configuration Module
# Locked-down public-facing kiosk mode

{ config, pkgs, ... }:

{
  # X11 and Desktop Environment
  services.xserver = {
    enable = true;
    
    # Lightweight display manager
    displayManager.lightdm = {
      enable = true;
      greeters.gtk.enable = true;
    };
    
    # Minimal desktop - XFCE for performance
    desktopManager.xfce = {
      enable = true;
      enableXfwm = false;  # No window manager decorations
    };
    
    # Disable screen saver and blanking
    displayManager.sessionCommands = ''
      xset s off
      xset -dpms
      xset s noblank
    '';
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

  # Minimal kiosk packages
  environment.systemPackages = with pkgs; [
    # Browser for kiosk (fullscreen)
    firefox
    
    # Minimal utilities
    htop
    
    # Network tools
    networkmanagerapplet
  ];

  # Exclude all unnecessary packages
  services.xserver.desktopManager.xfce.enableXfwm = false;
  services.xserver.desktopManager.xfce.noDesktop = false;

  # Auto-login to kiosk user (sif)
  services.displayManager.autoLogin = {
    enable = true;
    user = "sif";
  };

  # Kiosk-specific sif user settings
  # Start application in fullscreen automatically
  # This can be customized per kiosk
  
  # Disable virtual consoles (prevent Ctrl+Alt+F1 escape)
  services.getty.autologinUser = "sif";
  
  # Lock down the desktop
  # Remove right-click, panels, etc.
  programs.dconf.enable = true;
  
  # Auto-restart on crash
  systemd.services."autorestart-x" = {
    description = "Auto-restart X on failure";
    serviceConfig = {
      Type = "oneshot";
      Restart = "always";
      RestartSec = "5s";
    };
  };

  # No automatic updates (control updates carefully for kiosks)
  system.autoUpgrade = {
    enable = false;
    allowReboot = false;
  };

  # Disable sleep/suspend/hibernate - always on
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Automatic reboot at 3 AM daily (to clear any issues)
  systemd.timers."daily-reboot" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      OnCalendar = "*-*-* 03:00:00";
      Persistent = true;
    };
  };

  systemd.services."daily-reboot" = {
    script = "systemctl reboot";
    serviceConfig = {
      Type = "oneshot";
    };
  };
}
