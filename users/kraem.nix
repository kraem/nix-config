{ config, pkgs, ... }:
let
  sshPubKeys = (import ../secrets.nix).sshPubKeys;
  hashedPasswords = (import ../secrets.nix).hashedPasswords;
in
{

  users.users.kraem = {
    hashedPassword =
      hashedPasswords.userKraem;
    openssh.authorizedKeys.keys = [
      sshPubKeys.ursa
      sshPubKeys.frigate
    ];
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "wheel"
    ];
  };

}