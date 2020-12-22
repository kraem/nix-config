{ config, pkgs, ... }:

let
  secrets = (import ../../secrets/secrets.nix);
in

{

  systemd.tmpfiles.rules = [
    "d /bak/synapse/dump_pg/ 0750 postgres postgres -"
    "d /bak/synapse/dump_varlib/ 0700 synapsebak synapsebak -"
  ];

  users.groups.synapsebak = { };

  users.extraUsers.synapsebak = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      secrets.sshPubKeys.synapsebak
    ];
    group = "synapsebak";
    extraGroups = [
      "postgres"
    ];
  };

  # TODO copy logic from postgresqlBackup into our own synapse-backup
  # that way we don't need to add user synapsebak to group postgres
  # and we can tighten permissions.
  # (although group postgres has no permissions in /var/lib/postgres)
  services.postgresql.enable = true;
  services.postgresqlBackup.enable = true;
  services.postgresqlBackup.databases = [ "postgres" "matrix-synapse" ];
  services.postgresqlBackup.location = "/bak/synapse/dump_pg";
  services.postgresqlBackup.startAt = "*-*-* 05:25:00";

  systemd = {
    timers = {
      synapse-backup = {
        wantedBy = [ "timers.target" ];
        partOf = [ "synapse-backup.service" ];
        timerConfig.OnCalendar = "*-*-* 05:25:00";
        timerConfig.Persistent = "true";
        enable = false;
      };
    };

    services = {
      synapse-backup = {
        wantedBy = [ "postgresqlBackup-matrix-synapse.service" ];
        serviceConfig = {
          User = "root";
          Type = "oneshot";
        };
        script = ''
          set -e
          tar czvf /bak/synapse/dump_varlib/var-lib-matrix-synapse.tar.xz /var/lib/matrix-synapse
          chown synapsebak:synapsebak /bak/synapse/dump_varlib/*
          chmod -R 0660 /bak/synapse/dump_pg/*
          chmod -R 0600 /bak/synapse/dump_varlib/*
        '';
        path = [
          pkgs.coreutils
          pkgs.bash
          pkgs.gnutar
          pkgs.gzip
        ];
        enable = true;
      };
    };
  };

}
