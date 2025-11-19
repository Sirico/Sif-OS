# Printing Configuration Module
# CUPS and label printer support

{ config, pkgs, lib, ... }:

{
  # Enable CUPS and make sure all queues are discoverable on the LAN.
  services.printing = {
    enable = true;
    startWhenNeeded = false;
    drivers = with pkgs; [
      # Common printer drivers
      gutenprint
      gutenprintBin
      hplip

      # Generic drivers
      cups-filters

      # Label printer support (Dymo, Brother, Zebra, etc.)
      # Add specific drivers as needed
    ];
    webInterface = true;
    defaultShared = true;
    browsing = true;
    listenAddresses = [ "*:631" ];
    allowFrom = [ "all" ];
    extraConf = ''
      # Enable raw printing (useful for label printers) and force sharing.
      FileDevice Yes
      SharePrinters Yes
      DefaultShared Yes
    '';
  };

  # Enable Avahi for network printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Packages for printer management
  environment.systemPackages = with pkgs; [
    system-config-printer  # GUI printer configuration
  ];

  # systemd still installs the upstream cups.socket unit from the cups
  # package, so explicitly disable it to avoid socket activation entirely.
  systemd.sockets.cups.enable = lib.mkForce false;
}
