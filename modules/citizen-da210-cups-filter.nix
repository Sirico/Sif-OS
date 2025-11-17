
{ config, pkgs, ... }:

{
  # Install rastertocls filter to CUPS filter directory using environment.etc, source from repo
  # Build a small package that installs the rastertocls binary into
  # $out/lib/cups/filter/rastertocls so it becomes available in the
  # system profile (e.g. /run/current-system/sw/lib/cups/filter/...)
  rastertoclsPkg = pkgs.stdenv.mkDerivation rec {
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
      license = licenses.unfree; # binary blob
      platforms = platforms.linux;
    };
  };
in

{
  # Add the built package to the system profile so CUPS can find the
  # filter under the store/profile lib path. This avoids writing to
  # /etc during evaluation and avoids /etc collisions.
  environment.systemPackages = (config.environment.systemPackages or []) ++ [ rastertoclsPkg ];
}
}
