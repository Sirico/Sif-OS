{ config, lib, pkgs, ... }:

let
  cfg = config.sifos.printing.samba;
in
{
  options.sifos.printing.samba.enable = lib.mkEnableOption "Expose CUPS printers over Samba/SMB";

  config = lib.mkIf cfg.enable {
    services.samba = {
      enable = true;
      # Use full build so CUPS printing is supported.
      package = pkgs.sambaFull;
      openFirewall = true;
      settings = {
        global = {
          "load printers" = "yes";
          printing = "cups";
          "printcap name" = "cups";
        };
        printers = {
          comment = "All Printers";
          path = "/var/spool/samba";
          printable = "yes";
          browseable = "yes";
          "guest ok" = "yes";
        };
        "print$" = {
          comment = "Printer Drivers";
          path = "/var/lib/samba/printers";
          browseable = "yes";
          "guest ok" = "yes";
          writeable = "no";
        };
      };
    };

    users.groups.lpadmins = { };
    users.users.samba-printer = {
      isSystemUser = true;
      group = "lpadmins";
    };
    services.avahi.publish.enable = true;

    # Ensure Samba printer share paths exist.
    systemd.tmpfiles.rules = [
      "d /var/spool/samba 1777 root root -"
      "d /var/lib/samba/printers 1775 root root -"
    ];
  };
}
