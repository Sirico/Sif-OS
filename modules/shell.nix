# Shell Configuration Module
# Configures zsh with Oh My Zsh for improved terminal experience

{ config, pkgs, lib, ... }:

{
  # Install zsh and required packages
  programs.zsh = {
    enable = true;
    
    # Enable Oh My Zsh
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";  # Default theme, can be customized
      plugins = [
        "git"
        "sudo"
        "docker"
        "kubectl"
        "systemd"
        "ssh-agent"
      ];
    };
    
    # Enable auto-suggestions
    autosuggestions.enable = true;
    
    # Enable syntax highlighting
    syntaxHighlighting.enable = true;
    
    # Shell aliases
    shellAliases = {
      ll = "ls -lah";
      ".." = "cd ..";
      "..." = "cd ../..";
      update = "sudo nixos-rebuild switch";
      test-config = "sudo nixos-rebuild test";
      rebuild = "sudo nixos-rebuild switch";
    };
    
    # Additional configuration
    interactiveShellInit = ''
      # Custom prompt color
      export PROMPT='%F{cyan}%n@%m%f:%F{yellow}%~%f$ '
      
      # History settings
      HISTSIZE=10000
      SAVEHIST=10000
      setopt SHARE_HISTORY
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_SPACE
    '';
  };
  
  # Set default shell for admin user
  users.users.admin.shell = pkgs.zsh;
  
  # Install additional useful shell tools
  environment.systemPackages = with pkgs; [
    zsh-completions
    nix-zsh-completions
  ];
}
