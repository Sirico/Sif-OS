{ config, lib, pkgs, ... }:

let
  cfg = config.sifos.printing.samba;
in
{
  options.sifos.printing.samba.enable = lib.mkEnableOption "Expose CUPS printers over Samba/SMB";

  config = lib.mkIf cfg.enable {
    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        "load printers" = "yes";
        printing = "cups";
        "printcap name" = "cups";
      };
      shares = {
        printers = {
          comment = "All Printers";
          path = "/var/spool/samba";
          printable = true;
          browseable = true;
          "guest ok" = true;
        };
        "print$" = {
          comment = "Printer Drivers";
          path = "/var/lib/samba/printers";
          browseable = true;
          "guest ok" = true;
          writeable = false;
        };
      };
    };

    users.groups.lpadmins = { };
    users.users.samba-printer = {
      isSystemUser = true;
      group = "lpadmins";
    };
    services.avahi.publish.enable = true;
  };
}
