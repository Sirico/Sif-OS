# Backup Configuration Module
# Automated backups using Restic for user data and application state

{ config, pkgs, lib, ... }:

{
  options = {
    sifos.backup = {
      enable = lib.mkEnableOption "SifOS backup service";
      
      repository = lib.mkOption {
        type = lib.types.str;
        default = "/backup";
        description = "Backup repository location (local path, S3, B2, etc.)";
        example = "/mnt/backup or s3:s3.amazonaws.com/bucket-name";
      };
      
      passwordFile = lib.mkOption {
        type = lib.types.str;
        default = "/root/restic-password";
        description = "Path to file containing the Restic repository password";
      };
      
      schedule = lib.mkOption {
        type = lib.types.str;
        default = "daily";
        description = "Backup schedule (systemd timer format)";
      };
      
      paths = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "/home/sif"
          "/home/admin"
          "/var/lib"
        ];
        description = "Paths to backup";
      };
      
      exclude = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "/home/*/.cache"
          "/home/*/.local/share/Trash"
          "*.tmp"
          "*.temp"
        ];
        description = "Patterns to exclude from backup";
      };
      
      retention = {
        daily = lib.mkOption {
          type = lib.types.int;
          default = 7;
          description = "Number of daily backups to keep";
        };
        
        weekly = lib.mkOption {
          type = lib.types.int;
          default = 4;
          description = "Number of weekly backups to keep";
        };
        
        monthly = lib.mkOption {
          type = lib.types.int;
          default = 6;
          description = "Number of monthly backups to keep";
        };
        
        yearly = lib.mkOption {
          type = lib.types.int;
          default = 2;
          description = "Number of yearly backups to keep";
        };
      };
    };
  };

  config = lib.mkIf config.sifos.backup.enable {
    # Install Restic
    environment.systemPackages = with pkgs; [
      restic
    ];

    # Restic backup service
    services.restic.backups.sifos = {
      repository = config.sifos.backup.repository;
      passwordFile = config.sifos.backup.passwordFile;
      
      paths = config.sifos.backup.paths;
      exclude = config.sifos.backup.exclude;
      
      timerConfig = {
        OnCalendar = config.sifos.backup.schedule;
        Persistent = true;
      };
      
      pruneOpts = [
        "--keep-daily ${toString config.sifos.backup.retention.daily}"
        "--keep-weekly ${toString config.sifos.backup.retention.weekly}"
        "--keep-monthly ${toString config.sifos.backup.retention.monthly}"
        "--keep-yearly ${toString config.sifos.backup.retention.yearly}"
      ];
      
      # Initialize repository if it doesn't exist
      initialize = true;
    };

    # Backup script for manual use
    environment.systemPackages = with pkgs; [
      (pkgs.writeScriptBin "sifos-backup" ''
        #!${pkgs.bash}/bin/bash
        set -e
        
        echo "Starting SifOS backup..."
        systemctl start restic-backups-sifos.service
        
        echo "Checking backup status..."
        systemctl status restic-backups-sifos.service
        
        echo "Recent snapshots:"
        restic -r ${config.sifos.backup.repository} \
               -p ${config.sifos.backup.passwordFile} \
               snapshots --latest 5
      '')
      
      (pkgs.writeScriptBin "sifos-restore" ''
        #!${pkgs.bash}/bin/bash
        set -e
        
        if [ $# -lt 2 ]; then
          echo "Usage: sifos-restore <snapshot-id> <target-path>"
          echo ""
          echo "Available snapshots:"
          restic -r ${config.sifos.backup.repository} \
                 -p ${config.sifos.backup.passwordFile} \
                 snapshots
          exit 1
        fi
        
        SNAPSHOT="$1"
        TARGET="$2"
        
        echo "Restoring snapshot $SNAPSHOT to $TARGET..."
        restic -r ${config.sifos.backup.repository} \
               -p ${config.sifos.backup.passwordFile} \
               restore "$SNAPSHOT" --target "$TARGET"
        
        echo "Restore complete!"
      '')
    ];
  };
}
