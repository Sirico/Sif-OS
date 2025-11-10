# SifOS Configuration
# Thin Client OS for Wyse 5070 and similar hardware
# Designed for remote dispatch stations with RDP/Remmina access

{ config, pkgs, ... }:

{
  imports =
    [ 
      ./nixos/hardware-configuration.nix
      ./modules/users.nix
      ./modules/remote-access.nix
      ./modules/printing.nix
      ./modules/remmina.nix
      # Company branding (dark theme with yellow accents)
      ./modules/branding.nix
      # Machine-specific config (hostname and machine type module)
      ./machine-config.nix
    ];

  # System Identity
  # Note: hostname is set in machine-config.nix per-machine

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.networkmanager.enable = true;

  # Localization
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Keyboard
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };
  console.keyMap = "uk";

  # Allow unfree packages (needed for some drivers)
  nixpkgs.config.allowUnfree = true;

  # System State Version
  system.stateVersion = "25.05";
}
