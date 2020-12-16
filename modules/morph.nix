{ config, pkgs, ... }:
let
  sshPubKeys = (import ../secrets.nix).sshPubKeys;
  hashedPasswords = (import ../secrets.nix).hashedPasswords;
  binaryCachePubKeys = (import ../secrets.nix).binaryCachePubKeys;
in
{

  nix.binaryCachePublicKeys = [
    binaryCachePubKeys.ursa
  ];

  users.groups.morph = { };

  users.users.morph = {
    isSystemUser = false;
    isNormalUser = true;
    createHome = false;
    home = "/var/empty";
    group = "morph";
    extraGroups = [
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      sshPubKeys.ursa
    ];
    hashedPassword = hashedPasswords.userMorph;
  };

}
