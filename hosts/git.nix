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

    ../modules/wireguard/client
  ];

  networking.hostName = "git";
  networking.firewall.allowPing = true;

  my.wireguardClient = {
    enable = true;
    disableOnBoot = false;
    provisionWireguard = false;
    serverEndpoint = secrets.hosts.lb1.pubDomain;
    serverPort = secrets.wireguard.port;
    serverPublicKey = secrets.wireguard.pubKeys.lb1;
    serverDns = secrets.hosts.lb1.domain;
    allowedIPs = "10.0.0.0/24";
    clientAddress = secrets.hosts.git.domain;
    clientPrivateKeyFile = "/var/lib/wg/priv.key";
  };

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
