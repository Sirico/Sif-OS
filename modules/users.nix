# User Configuration Module
# Defines standard users for SifOS thin clients
#
# Security model:
# - admin: Full system access, can update configurations, requires sudo
# - sif: Limited user, can only use applications, no system access

{ config, pkgs, ... }:

{
  # Define users
  users.users = {
    # Admin user (Darren) - for remote management
    admin = {
      isNormalUser = true;
      description = "Administrator";
      extraGroups = [ 
        "networkmanager" 
        "wheel"           # sudo access
        "lp"              # printer access
        "audio"
        "video"
      ];
      # Add your SSH public key here for passwordless access
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIISILWvOua7RNEwVElEPYd7xSJoO7JB2J5HRZg/4r1ze darrenjgregory@gmail.com"
      ];
      packages = with pkgs; [
        # Admin tools
        vim
        htop
        tmux
        git
      ];
    };

    # Standard user (sif) - for thin client operations
    sif = {
      isNormalUser = true;
      description = "SIF User";
      extraGroups = [ 
        "networkmanager"
        "lp"              # printer access
        "audio"
        "video"
      ];
      # Set password for screen unlock (auto-login still works)
      # Password: sif2024
      hashedPassword = "$6$uReu0dzjHvqZowpe$lVWGmB45OlIUwamOatkm7Ak57nC.qu.6NOV.T66LTlvZMJofJjyayyvKaiYkNCncb.5I2UUXJTqdu9s25bZrM/";
      packages = with pkgs; [
        # User tools (minimal)
      ];
    };
  };

  # Enable automatic login for sif user (thin client mode)
  services.displayManager.autoLogin = {
    enable = true;
    user = "sif";
  };

  # Workaround for GNOME autologin
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Automatically unlock GNOME Keyring on auto-login
  # This prevents keyring password prompts for the auto-logged-in user
  security.pam.services.gdm.enableGnomeKeyring = true;
  security.pam.services.gdm-autologin = {
    enableGnomeKeyring = true;
    text = ''
      auth     required  pam_succeed_if.so user ingroup users
      auth     optional  pam_gnome_keyring.so
      account  include   gdm
      password include   gdm
      session  include   gdm
      session  optional  pam_gnome_keyring.so auto_start
    '';
  };

  # One-time cleanup: Remove any existing keyring with password
  # This allows auto-login to create a new keyring with blank password
  system.activationScripts.cleanupKeyring = ''
    if [ -d /home/sif/.local/share/keyrings ]; then
      rm -f /home/sif/.local/share/keyrings/login.keyring
      rm -f /home/sif/.local/share/keyrings/*.keyring
    fi
  '';

  # Security: Allow wheel group to use sudo without password for admin
  security.sudo.extraRules = [
    {
      users = [ "admin" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
