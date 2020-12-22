{ config, pkgs, ... }:
let
  secrets = (import ../secrets/secrets.nix);
in
{

  nix.binaryCachePublicKeys = [
    secrets.binaryCachePubKeys.ursa
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
      secrets.sshPubKeys.ursa
    ];
    hashedPassword = secrets.hashedPasswords.userMorph;
  };

}
