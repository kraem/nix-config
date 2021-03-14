{ config, pkgs, ... }:

{

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  networking.enableIPv6 = false;
  #networking.resolvconf.useLocalResolver = true;

  imports = [
    ./networkmanager.nix
  ];

}
