{ config, pkgs, ... }:
# TODO make module out of this
let
  synapse = (import ../../secrets.nix).synapse;
  sshPort = (builtins.toString (builtins.head config.services.openssh.ports));
  sshKeyPath = "/secrets/lb1/ssh/synapsebak_rsa";
  synapseBakUser = "synapsebak";
  bakPathLocal = "/data/enc/bak/synapse/";
  bakPathRemote = "/bak/synapse/";
  backupServiceName = "synapse-backup-fetcher";
in
{
  systemd.tmpfiles.rules = [
    "d ${bakPathLocal} 0711 ${synapseBakUser} - -"
  ];

  users.extraUsers."${synapseBakUser}" = {
    isNormalUser = true;
  };
  users.groups."${synapseBakUser}" = { };

  systemd = {
    timers = {
      "${backupServiceName}" = {
        wantedBy = [ "timers.target" ];
        partOf = [ "synapse-backup.service" ];
        timerConfig.OnCalendar = "*-*-* 06:00:00";
        timerConfig.Persistent = "true";
        enable = true;
      };
    };

    services = {
      "${backupServiceName}" = {
        serviceConfig = {
          User = "${synapseBakUser}";
          Type = "oneshot";
        };
        script = ''
          ${pkgs.rsync}/bin/rsync -v -a -e "ssh -i ${sshKeyPath} -p ${sshPort} -v" ${synapseBakUser}@${synapse.domain}:${bakPathRemote}/* ${bakPathLocal}
        '';
        path = [
          pkgs.coreutils
          pkgs.bash
          pkgs.rsync
          pkgs.openssh
        ];
        enable = true;
      };
    };
  };
}
