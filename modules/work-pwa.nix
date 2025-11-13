{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.workPWA;
  
  # Create desktop entry for a PWA
  mkPWADesktopEntry = { name, displayName, url, icon, browser ? "chromium" }:
    pkgs.writeTextFile {
      name = "${name}.desktop";
      destination = "/share/applications/${name}.desktop";
      text = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=${displayName}
        Comment=Launch ${displayName} as PWA
        Exec=${browser} --app=${url} --class=${name} --user-data-dir=$HOME/.config/${name}-pwa --window-name="${displayName}"
        Icon=${icon}
        Terminal=false
        Categories=Office;Network;
        StartupWMClass=${name}
      '';
    };

  # Create all PWA desktop entries
  sifOutlookPWA = mkPWADesktopEntry {
    name = "sif-outlook";
    displayName = "SIF Outlook";
    url = "https://outlook.office.com/mail/";
    icon = "microsoft-outlook";
  };

  sifTeamsPWA = mkPWADesktopEntry {
    name = "sif-teams";
    displayName = "SIF Teams";
    url = "https://teams.microsoft.com/";
    icon = "teams";
  };

  peiOutlookPWA = mkPWADesktopEntry {
    name = "pei-outlook";
    displayName = "PEI Outlook";
    url = "https://outlook.office.com/mail/";
    icon = "microsoft-outlook";
  };

  peiTeamsPWA = mkPWADesktopEntry {
    name = "pei-teams";
    displayName = "PEI Teams";
    url = "https://teams.microsoft.com/";
    icon = "teams";
  };

in {
  options.workPWA = {
    enable = mkEnableOption "Work PWA launchers for SIF and PEI";
    
    browser = mkOption {
      type = types.enum [ "chromium" "google-chrome" "brave" "microsoft-edge" ];
      default = "chromium";
      description = "Browser to use for PWAs";
    };
  };

  config = mkIf cfg.enable {
    # Add helper scripts
    environment.shellAliases = {
      # Quick launchers
      "sif-outlook" = "${cfg.browser} --app=https://outlook.office.com/mail/ --class=sif-outlook --user-data-dir=$HOME/.config/sif-outlook-pwa --window-name='SIF Outlook' &";
      "sif-teams" = "${cfg.browser} --app=https://teams.microsoft.com/ --class=sif-teams --user-data-dir=$HOME/.config/sif-teams-pwa --window-name='SIF Teams' &";
      "pei-outlook" = "${cfg.browser} --app=https://outlook.office.com/mail/ --class=pei-outlook --user-data-dir=$HOME/.config/pei-outlook-pwa --window-name='PEI Outlook' &";
      "pei-teams" = "${cfg.browser} --app=https://teams.microsoft.com/ --class=pei-teams --user-data-dir=$HOME/.config/pei-teams-pwa --window-name='PEI Teams' &";
    };

    # Install the browser, PWA desktop entries, and launcher scripts
    environment.systemPackages = with pkgs; [
      # Install the chosen browser
      (if cfg.browser == "chromium" then chromium
       else if cfg.browser == "google-chrome" then google-chrome
       else if cfg.browser == "brave" then brave
       else if cfg.browser == "microsoft-edge" then microsoft-edge
       else chromium)
      
      # Install PWA desktop entries
      sifOutlookPWA
      sifTeamsPWA
      peiOutlookPWA
      peiTeamsPWA
      
      # Launcher scripts
      (pkgs.writeScriptBin "work-launch-all" ''
        #!${pkgs.bash}/bin/bash
        
        echo "🚀 Launching all work applications..."
        echo ""
        
        echo "📧 Starting SIF Outlook..."
        ${cfg.browser} --app=https://outlook.office.com/mail/ --class=sif-outlook --user-data-dir=$HOME/.config/sif-outlook-pwa --window-name="SIF Outlook" &
        sleep 2
        
        echo "💬 Starting SIF Teams..."
        ${cfg.browser} --app=https://teams.microsoft.com/ --class=sif-teams --user-data-dir=$HOME/.config/sif-teams-pwa --window-name="SIF Teams" &
        sleep 2
        
        echo "📧 Starting PEI Outlook..."
        ${cfg.browser} --app=https://outlook.office.com/mail/ --class=pei-outlook --user-data-dir=$HOME/.config/pei-outlook-pwa --window-name="PEI Outlook" &
        sleep 2
        
        echo "💬 Starting PEI Teams..."
        ${cfg.browser} --app=https://teams.microsoft.com/ --class=pei-teams --user-data-dir=$HOME/.config/pei-teams-pwa --window-name="PEI Teams" &
        
        echo ""
        echo "✅ All work applications launched!"
        echo ""
        echo "Each app has its own separate profile and login."
        echo "Sign in to each one with the appropriate company account."
      '')

      (pkgs.writeScriptBin "work-launch-sif" ''
        #!${pkgs.bash}/bin/bash
        echo "🚀 Launching SIF applications..."
        ${cfg.browser} --app=https://outlook.office.com/mail/ --class=sif-outlook --user-data-dir=$HOME/.config/sif-outlook-pwa --window-name="SIF Outlook" &
        sleep 2
        ${cfg.browser} --app=https://teams.microsoft.com/ --class=sif-teams --user-data-dir=$HOME/.config/sif-teams-pwa --window-name="SIF Teams" &
        echo "✅ SIF Outlook and Teams launched!"
      '')

      (pkgs.writeScriptBin "work-launch-pei" ''
        #!${pkgs.bash}/bin/bash
        echo "🚀 Launching PEI applications..."
        ${cfg.browser} --app=https://outlook.office.com/mail/ --class=pei-outlook --user-data-dir=$HOME/.config/pei-outlook-pwa --window-name="PEI Outlook" &
        sleep 2
        ${cfg.browser} --app=https://teams.microsoft.com/ --class=pei-teams --user-data-dir=$HOME/.config/pei-teams-pwa --window-name="PEI Teams" &
        echo "✅ PEI Outlook and Teams launched!"
      '')
    ];
  };
}
