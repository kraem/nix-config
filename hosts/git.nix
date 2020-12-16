{ config, pkgs, ... }:
let
  sshPubKeys = (import ../secrets.nix).sshPubKeys;
  hashedPasswords = (import ../secrets.nix).hashedPasswords;
in
{
  imports = [
    ../hardware/git.nix

    ../modules/morph.nix
    ../modules/sshd.nix

    ../profiles/core

  ];

  networking.hostName = "git";
  networking.firewall.allowPing = true;

  users.groups.git = { };

  users.extraUsers.git = {
    hashedPassword =
      hashedPasswords.userGit;
    openssh.authorizedKeys.keys = [
      sshPubKeys.ursa
      sshPubKeys.frigate
    ];
    group = "git";
    isNormalUser = true;
    uid = 1001;
    shell = "${pkgs.git}/bin/git-shell";
    extraGroups = [
      "wheel"
    ];
  };

}
