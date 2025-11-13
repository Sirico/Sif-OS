# Shell Configuration Module

This module configures zsh with Oh My Zsh for an improved terminal experience.

## Features

- **Oh My Zsh**: Popular zsh framework with themes and plugins
- **Auto-suggestions**: Command auto-suggestions based on history
- **Syntax highlighting**: Real-time syntax highlighting for commands
- **Useful aliases**: Common shortcuts for NixOS operations
- **Git integration**: Enhanced git support via Oh My Zsh plugin

## Enabled For

- **Workstation** machines (developers)
- **Office** machines (power users)
- **Server** machines (administrators)

The admin user gets zsh as their default shell with Oh My Zsh configured.

## Plugins Included

- `git` - Git aliases and functions
- `sudo` - Press ESC twice to prefix previous command with sudo
- `docker` - Docker completions and aliases
- `kubectl` - Kubernetes completions
- `systemd` - Systemd shortcuts
- `ssh-agent` - SSH agent management

## Aliases

- `ll` - List files in long format with hidden files
- `..` - Go up one directory
- `...` - Go up two directories
- `update` - Run `sudo nixos-rebuild switch`
- `test-config` - Run `sudo nixos-rebuild test`
- `rebuild` - Run `sudo nixos-rebuild switch`

## Customization

To customize the theme or add more plugins, edit `modules/shell.nix`:

```nix
programs.zsh.ohMyZsh = {
  theme = "robbyrussell";  # Change theme here
  plugins = [
    "git"
    "sudo"
    # Add more plugins here
  ];
};
```

Popular themes: `agnoster`, `powerlevel10k`, `robbyrussell`, `bira`

## Notes

- The sif user (thin client user) keeps the default bash shell for simplicity
- Thin client machines don't include this module as they're focused on GUI applications
