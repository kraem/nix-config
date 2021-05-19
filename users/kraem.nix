{ config, pkgs, ... }:
let
  secrets = (import ../secrets/secrets.nix);
in
{
  users.users.kraem = {
    hashedPassword =
      secrets.hashedPasswords.userKraem;
    openssh.authorizedKeys.keys = [
      secrets.ssh.pubKeys.ursa
      secrets.ssh.pubKeys.frigate
    ];
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "wheel"
      "systemd-journal"
    ];
  };

  home-manager.users.kraem = { ... }: {
    programs.direnv.enable = true;
    programs.direnv.enableNixDirenvIntegration = true;
  };
}
