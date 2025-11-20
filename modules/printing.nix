# Printing Configuration Module
# CUPS and label printer support

{ pkgs, ... }:

{
  # Enable CUPS and make sure all queues are discoverable on the LAN.
  services.printing = {
    enable = true;
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
}
