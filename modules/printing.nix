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

  # Run cupsd as a normal service instead of socket-activated (-f keeps it in
  # the foreground for systemd supervision).
  systemd.services.cups = lib.mkMerge [
    {
      unitConfig = {
        Requires = lib.mkForce [ ];
        After = lib.mkForce [ "network.target" ];
        Wants = lib.mkForce [ "network.target" ];
      };
      serviceConfig = lib.mkForce {
        Type = "simple";
        ExecStart = "${config.services.printing.package}/sbin/cupsd -f";
      };
      wantedBy = lib.mkForce [ "multi-user.target" "printer.target" ];
    }
  ];
}
