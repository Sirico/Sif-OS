# Printing Configuration Module
# CUPS and label printer support

{ config, pkgs, ... }:

{
  # Enable CUPS
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
  };

  # Enable Avahi for network printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # IPP Everywhere support (modern driverless printing)
  services.printing.webInterface = true;
  # Share queues by default so downstream clients (e.g. Windows VMs) can discover them
  services.printing.defaultShared = true;

  # Packages for printer management
  environment.systemPackages = with pkgs; [
    system-config-printer  # GUI printer configuration
  ];

  # Allow printers to be shared
  services.printing.browsing = true;
  services.printing.defaultShared = true;

  # Additional CUPS configuration for label printers
  services.printing.extraConf = ''
    # Enable raw printing (useful for label printers)
    FileDevice Yes
  '';
}
