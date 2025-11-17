{
  description = "SifOS - Multi-Purpose NixOS System with Fleet Management";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    
    # Optional: Reference your personal nixos-config for darren-workstation
    # personal-config = {
    #   url = "path:/home/darren/nixos-config";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, ... } @ inputs:
    let
      system = "x86_64-linux";
      
      # Common module imports for all SifOS machines
      commonModules = [
        ./modules/users.nix
        ./modules/remote-access.nix
        ./modules/printing.nix
        ./modules/branding.nix
      ];
      
      # Function to create a SifOS configuration
      mkSifOSSystem = hostname: machineType: extraModules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = commonModules ++ [
            ./configuration.nix
            machineType
            {
              networking.hostName = hostname;
            }
          ] ++ extraModules;
        };
    in
    {
      # Machine configurations
      nixosConfigurations = {
        # Thin clients
        "thin-client-6" = mkSifOSSystem "thin-client-6" ./machine-types/thin-client.nix [
          ./nixos/hardware-configuration-thin-client-6.nix
        ];
        "sifos-thin-client-6" = mkSifOSSystem "sifos-thin-client-6" ./machine-types/thin-client.nix [];
        
        # Office machines
        "sifos-office-1" = mkSifOSSystem "sifos-office-1" ./machine-types/office.nix [];
        
        # Workstations
        "sifos-workstation-1" = mkSifOSSystem "sifos-workstation-1" ./machine-types/workstation.nix [];
        
        # Personal workstation (can optionally import from personal-config)
        "darren-workstation" = mkSifOSSystem "darren-workstation" ./machine-types/darren-workstation.nix [];
        
        # Servers
        "sifos-server-1" = mkSifOSSystem "sifos-server-1" ./machine-types/server.nix [];
        
        # Shop kiosks
        "sifos-kiosk-1" = mkSifOSSystem "sifos-kiosk-1" ./machine-types/shop-kiosk.nix [];
      };
      
      # Deployment helpers
      apps.${system} = {
        # Deploy to fleet via Tailscale
        fleet-deploy = {
          type = "app";
          program = "${self}/fleet-deploy.sh";
        };
        
        # Enroll new machine
        enroll = {
          type = "app";
          program = "${self}/enroll-machine.sh";
        };
      };
    };
}
