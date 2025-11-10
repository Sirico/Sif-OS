# Remmina Configuration
# Pre-configured RDP connections for Windows VMs

{ config, pkgs, ... }:

{
  # Ensure Remmina and plugins are installed
  environment.systemPackages = with pkgs; [
    remmina
    # RDP plugin is included by default
  ];

  # Create a directory for shared Remmina profiles
  # Place .remmina files here for all users
  environment.etc."skel/.local/share/remmina/.keep".text = "";
  
  # System-wide Remmina configuration
  # Users can add their own connections in ~/.local/share/remmina/
}
