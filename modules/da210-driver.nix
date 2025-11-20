{ config, lib, pkgs, ... }:

let
  cfg = config.sifos.printers.da210;

  # Build with the configuration's pkgs so nixpkgs config (allowUnfree) applies.
  da210Driver = pkgs.callPackage ../packages/da210-driver.nix { };
  libcups = "${pkgs.cups.lib}/lib/libcups.so.2";
  libgs = "${pkgs.ghostscript}/lib/libgs.so";
in
{
  options.sifos.printers.da210.enable = lib.mkEnableOption "Citizen / TSC DA-210 CUPS driver (filters, PPDs, backends)";

  config = lib.mkIf cfg.enable {
    # Make the driver visible to users (for the GUI tools) and to CUPS
    environment.systemPackages = lib.mkAfter [ da210Driver ];

    # Register driver content (filters/backends/PPDs) with cupsd so it picks
    # them up during driver enumeration.
    services.printing.drivers = lib.mkAfter [ da210Driver ];

    # Ensure cupsd and cups-browsed have the driver on PATH for any helper
    # lookups (e.g. backends invoked directly by the service).
    systemd.services.cups.path = lib.mkAfter [ da210Driver ];
    systemd.services."cups-browsed".path = lib.mkAfter [ da210Driver ];

    # The vendor filter hardcodes /usr lib paths when dlopening; create FHS
    # compatibility dirs/symlinks via tmpfiles so the filter can find libcups
    # and libgs at the expected locations (applies at boot and when running
    # `systemd-tmpfiles --create`).
    systemd.tmpfiles.rules = lib.mkAfter [
      "d /usr/lib 0755 root root - -"
      "d /usr/lib64 0755 root root - -"
      "d /usr/lib/x86_64-linux-gnu 0755 root root - -"
      "L /usr/lib64/libcups.so - - - - ${libcups}"
      "L /usr/lib64/libcups.so.2 - - - - ${libcups}"
      "L /usr/lib/libcups.so.2 - - - - ${libcups}"
      "L /usr/lib/x86_64-linux-gnu/libcups.so.2 - - - - ${libcups}"
      "L /usr/lib64/libgs.so - - - - ${libgs}"
      "L /usr/lib64/libgs.so.8 - - - - ${libgs}"
      "L /usr/lib/libgs.so - - - - ${libgs}"
      "L /usr/lib/x86_64-linux-gnu/libgs.so - - - - ${libgs}"
    ];
  };
}
