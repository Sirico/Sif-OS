{ pkgs, lib, ... }:

let
  cupsLdPath = lib.makeLibraryPath [
    pkgs.cups
    pkgs.cups.lib
    pkgs.cups-filters
    pkgs.libcupsfilters
  ];
in {
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
      libcupsfilters

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

  # Ensure cupsd/cups-browsed can dlopen libcups/libcupsfilters when filters use
  # their own dynamic loading logic.
  systemd.services.cups.environment.LD_LIBRARY_PATH = lib.mkForce cupsLdPath;
  systemd.services."cups-browsed".environment.LD_LIBRARY_PATH = lib.mkForce cupsLdPath;

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
