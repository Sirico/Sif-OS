
{ config, pkgs, ... }:

{
  # Install rastertocls filter to CUPS filter directory using environment.etc
  environment.etc."cups/filter/rastertocls".source = "/home/darren/Documents/usr/lib64/cups/filter/rastertocls";
}
