{ config, pkgs, lib, ... }:

with lib;

{
  options = { };

  config = {
    # Ensure the thermalprinterut helper is setuid root on activation. Use a
    # plain list here to avoid relying on `lib.mkOptionList` which may not be
    # available in certain evaluation contexts (previously caused "attribute
    # 'mkOptionList' missing" during rebuild).
    systemd.tmpfiles.rules = [
      # Format: <type> <path> <mode> <uid> <gid> <age> <argument>
      # 'z' sets permissions on an existing file
      "z /run/current-system/sw/share/tscbarcode/thermalprinterut 4755 root root - -"
    ];
  };

}
