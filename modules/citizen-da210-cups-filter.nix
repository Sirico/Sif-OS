{ config, pkgs, ... }:

{
  # Copy rastertocls filter to CUPS filter directory
  system.activationScripts.citizenDA210Filter = {
    text = ''
      install -m 755 /home/darren/Documents/usr/lib64/cups/filter/rastertocls /etc/cups/filter/rastertocls
    '';
  };
}
