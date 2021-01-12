{ config, pkgs, ... }:
let
  secrets = (import ../secrets/secrets.nix);
in
{
  imports = [
    ../hardware/synapse.nix

    ../modules/morph.nix
    ../modules/sshd.nix

    ../profiles/core

    ../modules/synapse
    ../modules/nginx

    ../modules/wireguard/client
  ];

  networking = {
    hostName = "synapse";
    domain = secrets.hosts.synapse.pubDomain;
  };

  my.wireguardClient = {
    enable = true;
    disableOnBoot = false;
    provisionWireguard = false;
    serverEndpoint = secrets.hosts.lb1.pubDomain;
    serverPort = secrets.wireguard.port;
    serverPublicKey = secrets.wireguard.pubKeys.lb1;
    serverDns = secrets.hosts.lb1.domain;
    allowedIPs = "10.0.0.0/24";
    clientAddress = secrets.hosts.synapse.domain;
    clientPrivateKeyFile = "/var/lib/wg/priv.key";
  };

}
