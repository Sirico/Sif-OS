# Per-Machine Configuration Template
# Copy this file for each thin client and customize

{ config, pkgs, ... }:

{
  # Unique hostname for this machine
  networking.hostName = "sifos-dispatch-01";  # CHANGE THIS

  # Machine-specific settings
  
  # Optional: Static IP configuration
  # networking.interfaces.enp1s0.ipv4.addresses = [{
  #   address = "192.168.1.100";
  #   prefixLength = 24;
  # }];
  # networking.defaultGateway = "192.168.1.1";
  # networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];

  # Optional: Machine-specific packages
  # environment.systemPackages = with pkgs; [
  #   # Add machine-specific tools here
  # ];

  # Optional: Pre-configured Remmina connections
  # See modules/remmina.nix for system-wide configuration
}
