{ config, pkgs, lib, ... }:

let
  rastertoclsPkg = pkgs.stdenv.mkDerivation {
    name = "rastertocls-filter";
    src = ../files/rastertocls;
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p "$out/lib/cups/filter"
      cp "$src" "$out/lib/cups/filter/rastertocls"
      chmod 0755 "$out/lib/cups/filter/rastertocls"
    '';
    meta = with pkgs.lib; {
      description = "rastertocls filter for CITIZEN DA210";
      license = lib.licenses.unfree;
      platforms = lib.platforms.linux;
    };
  };
in

{
  environment.systemPackages = lib.mkDefault [ rastertoclsPkg ];
}
