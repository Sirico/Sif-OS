{ config, pkgs, lib, ... }:

let
  adminPubPath = ../access/admin.pub;
  adminKey = if builtins.pathExists adminPubPath then builtins.readFile adminPubPath else "";
in
{
  imports = [ ../modules/remote-access.nix ];

  # Lightweight recovery profile: enable SSH, Tailscale (optional), and a local admin
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;

  # Minimal users: `recovery` user with sudo (no password) and an authorized key if provided
  users.users.recovery = {
    isNormalUser = true;
    description = "Recovery user";
    extraGroups = [ "wheel" "networkmanager" ];
    # lock password login; rely on SSH key
    password = null;
    openssh.authorizedKeys.keys = lib.mkIf (adminKey != "") [ adminKey ] [];
  };

  # Allow sudo for wheel without password in recovery scenario
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # Keep system minimal but useful for recovery operations
  environment.systemPackages = with pkgs; [ openssh jq ];

  # Basic networking services useful for recovery
  networking.networkmanager.enable = true;
  networking.hostName = "recovery-thin-client";

  # If a Tailscale auth key is present in ../access/tailscale-auth.key the
  # tailscale module in modules/remote-access.nix will pick it up and
  # automatically attempt to join the tailnet.
}
