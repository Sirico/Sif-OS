# SifOS Branding Module
# Custom Plymouth boot splash, wallpapers, user icons, and login screen

{ config, pkgs, lib, ... }:

{
  # Plymouth boot splash screen
  boot.plymouth = {
    enable = true;
    # Theme options: "bgrt", "spinner", "text", "details", "script", "solar", "spinfinity", "tribar"
    # Default is "bgrt" which shows manufacturer logo
    theme = "spinner";  # Change to custom theme once assets are added
    
    # Logo will be displayed during boot
    # logo = /etc/sifos/branding/plymouth-logo.png;
  };

  # GDM (GNOME Display Manager) logo and branding
  # Display manager is configured by machine-type modules
  # services.xserver.displayManager.gdm.banner = /etc/sifos/branding/login-banner.png;

  # LightDM (for XFCE/kiosk machines) branding
  # Applied when LightDM is enabled by machine type
  services.xserver.displayManager.lightdm.greeters.gtk = lib.mkIf config.services.xserver.displayManager.lightdm.enable {
    theme.name = "Adwaita-dark";
    iconTheme.name = "Adwaita";
    extraConfig = ''
      [greeter]
      background=/etc/sifos/branding/login-background.jpg
      logo=/etc/sifos/branding/company-logo.png
      theme-name=Adwaita-dark
    '';
  };

  # System-wide branding assets directory
  environment.etc = {
    # Company logo (for login screens, about dialogs)
    "sifos/branding/company-logo.png" = lib.mkIf (builtins.pathExists ../branding/company-logo.png) {
      source = ../branding/company-logo.png;
      mode = "0644";
    };
    
    # Plymouth boot logo (shown during boot)
    "sifos/branding/plymouth-logo.png" = lib.mkIf (builtins.pathExists ../branding/plymouth-logo.png) {
      source = ../branding/plymouth-logo.png;
      mode = "0644";
    };
    
    # Login screen background
    "sifos/branding/login-background.jpg" = lib.mkIf (builtins.pathExists ../branding/login-background.jpg) {
      source = ../branding/login-background.jpg;
      mode = "0644";
    };
    
    # Desktop wallpaper
    "sifos/branding/wallpaper.jpg" = lib.mkIf (builtins.pathExists ../branding/wallpaper.jpg) {
      source = ../branding/wallpaper.jpg;
      mode = "0644";
    };
    
    # User avatar/icon
    "sifos/branding/user-icon.png" = lib.mkIf (builtins.pathExists ../branding/user-icon.png) {
      source = ../branding/user-icon.png;
      mode = "0644";
    };
    
    # GNOME appearance settings (applied system-wide via dconf profile)
    "dconf/profile/user" = {
      text = ''
        user-db:user
        system-db:local
      '';
    };
    
    "dconf/db/local.d/01-appearance" = {
      text = ''
        # Dark mode with yellow accents
        [org/gnome/desktop/interface]
        color-scheme='prefer-dark'
        gtk-theme='Adwaita-dark'
        icon-theme='Adwaita'
        cursor-theme='Adwaita'
        accent-color='yellow'
        
        # Wallpaper
        [org/gnome/desktop/background]
        picture-uri='file:///etc/sifos/branding/wallpaper.jpg'
        picture-uri-dark='file:///etc/sifos/branding/wallpaper.jpg'
        picture-options='zoom'
        primary-color='#FDB714'
        secondary-color='#000000'
        
        # Lock screen wallpaper
        [org/gnome/desktop/screensaver]
        picture-uri='file:///etc/sifos/branding/login-background.jpg'
        primary-color='#FDB714'
        secondary-color='#000000'
        
        # Shell theme (panel, overview)
        [org/gnome/shell]
        favorite-apps=['firefox.desktop', 'org.remmina.Remmina.desktop', 'org.gnome.Nautilus.desktop']
        
        # Window manager preferences
        [org/gnome/desktop/wm/preferences]
        theme='Adwaita-dark'
        button-layout='appmenu:minimize,maximize,close'
      '';
    };
  };

  # Enable dconf for GNOME settings management
  programs.dconf.enable = true;

  # Apply dconf settings
  system.activationScripts.dconf-update = ''
    ${pkgs.dconf}/bin/dconf update
  '';

  # Set user face/icon for both users
  system.activationScripts.set-user-icons = lib.mkIf (builtins.pathExists ../branding/user-icon.png) ''
    # Copy user icon to admin user
    mkdir -p /var/lib/AccountsService/icons
    cp /etc/sifos/branding/user-icon.png /var/lib/AccountsService/icons/admin
    cp /etc/sifos/branding/user-icon.png /var/lib/AccountsService/icons/sif
    
    # Set icon in AccountsService config
    mkdir -p /var/lib/AccountsService/users
    
    cat > /var/lib/AccountsService/users/admin << EOF
[User]
Icon=/var/lib/AccountsService/icons/admin
EOF
    
    cat > /var/lib/AccountsService/users/sif << EOF
[User]
Icon=/var/lib/AccountsService/icons/sif
EOF
  '';

  # Install custom fonts if needed
  fonts.packages = with pkgs; [
    # Add your company fonts here if needed
    # liberation_ttf
    # dejavu_fonts
  ];

  # Additional packages for theming
  environment.systemPackages = with pkgs; [
    gnome-tweaks           # For additional GNOME customization
    dconf-editor           # For debugging dconf settings
  ];
}
