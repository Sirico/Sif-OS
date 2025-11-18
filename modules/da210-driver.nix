{ config, lib, pkgs, ... }:

let
  cfg = config.sifos.printers.da210;

  # Build with the configuration's pkgs so nixpkgs config (allowUnfree) applies.
  da210Driver = pkgs.callPackage ../packages/da210-driver.nix { };
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
  };
}
