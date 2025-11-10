# Remmina Configuration
# Pre-configured RDP connections for Windows VMs

{ config, pkgs, ... }:

{
  # Ensure Remmina and plugins are installed
  environment.systemPackages = with pkgs; [
    remmina
    # RDP plugin is included by default
  ];

  # Deploy pre-configured Remmina profiles for sif user
  # Profiles are stored in /etc/sifos/remmina-profiles/
  # and copied to user's home on first login
  
  environment.etc."sifos/remmina-profiles/windows-vm.remmina" = {
    text = builtins.readFile ../remmina-profiles/windows-vm.remmina;
    mode = "0644";
  };
  
  # Script to deploy Remmina profiles to user
  environment.etc."sifos/setup-remmina.sh" = {
    text = ''
      #!/bin/bash
      # Setup Remmina profiles for current user
      
      USER_HOME="$HOME"
      REMMINA_DIR="$USER_HOME/.local/share/remmina"
      SYSTEM_PROFILES="/etc/sifos/remmina-profiles"
      
      # Create Remmina config directory if it doesn't exist
      mkdir -p "$REMMINA_DIR"
      
      # Copy system profiles if they don't exist
      if [ -d "$SYSTEM_PROFILES" ]; then
          for profile in "$SYSTEM_PROFILES"/*.remmina; do
              if [ -f "$profile" ]; then
                  filename=$(basename "$profile")
                  if [ ! -f "$REMMINA_DIR/$filename" ]; then
                      cp "$profile" "$REMMINA_DIR/"
                      echo "Installed Remmina profile: $filename"
                  fi
              fi
          done
      fi
      
      echo "Remmina setup complete!"
    '';
    mode = "0755";
  };
  
  # Auto-setup Remmina profiles on first login for sif user
  systemd.user.services.remmina-setup = {
    description = "Setup Remmina profiles";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash /etc/sifos/setup-remmina.sh";
      RemainAfterExit = true;
    };
  };
}
