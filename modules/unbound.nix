{ config, pkgs, lib, ... }:
let
  secrets = import ../secrets/secrets.nix;
  domainGit = secrets.hosts.git.domain;
in
{
  services.unbound = {
    enable = true;
    settings = {
      forward-zone = [
        {
          name = ".";
          forward-addr = [ "1.1.1.1" ];
        }
      ];
      server = {
        access-control = [
          "10.0.0.0/16 allow"
          "192.168.1.0/16 allow"
        ];
        interface = [
          "0.0.0.0"
        ];
        local-data = [
          ''"git.lan A ${domainGit}"''
          ''"ne.bul.ae A 10.0.0.5"''
        ];
      };
    };
  };

  networking.firewall.allowedUDPPorts = [ 53 ];
  networking.firewall.allowedTCPPorts = [ 53 ];

  # This is set implicitely and we're unable to change this explicitely
  #networking.networkmanager.dns = "unbound";
  networking.networkmanager.dns = lib.mkForce "none";

}
