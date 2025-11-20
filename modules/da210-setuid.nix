{ pkgs, ... }:

let
  da210Driver = pkgs.callPackage ../packages/da210-driver.nix { };
in
{
  options = { };

  config = {
    # Ship an explicit tmpfiles override so systemd ignores the store copy and
    # doesn't try to chmod it (avoids the read-only fchmod error you hit).
    environment.etc."tmpfiles.d/01-da210.conf".text = ''
      x /run/current-system/sw/share/tscbarcode/thermalprinterut
    '';
  };
}
