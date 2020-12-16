{ config, pkgs, ... }:

{
  imports = [
    ./synapse.nix
    ./synapse-backup.nix
    ./prometheus-node-exporter.nix

    ../nginx
  ];
}
