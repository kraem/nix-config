{ config, pkgs, ... }:
let
  secrets = (import ../secrets/secrets.nix);
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
      secrets.hashedPasswords.userGit;
    openssh.authorizedKeys.keys = [
      secrets.ssh.pubKeys.ursa
      secrets.ssh.pubKeys.frigate
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
