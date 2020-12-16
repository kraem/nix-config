{ config, pkgs, ... }:
let
  synapse = (import ../secrets.nix).synapse;
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
    domain = synapse.domain;
  };

}
