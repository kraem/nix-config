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

  ];

  networking = {
    hostName = "synapse";
    domain = secrets.hosts.synapse.domain;
  };

}
