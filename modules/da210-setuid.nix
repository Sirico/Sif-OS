{ config, pkgs, lib, ... }:

with lib;

{
  options = { };

  config = {
    systemd.tmpfiles.rules = lib.mkOptionList (
      [ # Ensure the thermalprinterut helper is setuid root on activation
        # Format: <type> <path> <mode> <uid> <gid> <age> <argument>
        # 'f' creates a file and sets mode/owner; 'z' sets permissions on existing
        "z /run/current-system/sw/share/tscbarcode/thermalprinterut 4755 root root - -"
      ]
    );
  };

}
