{ config, pkgs, ... }:
let
  secrets = (import ../secrets/secrets.nix);
in
{

  users.users.kraem = {
    hashedPassword =
      secrets.hashedPasswords.userKraem;
    openssh.authorizedKeys.keys = [
      secrets.sshPubKeys.ursa
      secrets.sshPubKeys.frigate
    ];
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "wheel"
    ];
  };

}
