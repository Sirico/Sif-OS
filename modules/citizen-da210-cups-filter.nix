
{ config, pkgs, ... }:

{
  # Install rastertocls filter to CUPS filter directory using environment.etc, source from repo
  environment.etc."cups/filter/rastertocls" = {
    source = ../files/rastertocls;
    mode = "0755";
  };
}
