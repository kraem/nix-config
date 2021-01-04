{ config, pkgs, lib, ... }:

{
  services.unbound = {
    enable = true;
    #enableRemoteAccess = true;
    forwardAddresses = [
      "1.1.1.1"
    ];
    allowedAccess = [
      "10.0.0.0/16"
      "192.168.1.0/16"
    ];
    interfaces = [
      "0.0.0.0"
    ];
    extraConfig = ''
      # local-data: "nebulae.lan A 10.0.0.1"

      #  interface: 0.0.0.0
      #  do-ip4: yes
      #  do-ip6: no
      #  do-udp: yes
      #  do-tcp: yes
      #  access-control: 10.0.0.0/24 allow
      #  access-control: 127.0.0.0/8 allow
      #  access-control: 192.168.0.0/16 allow
      #  verbosity: 1
         log-queries: yes
    '';
  };

  networking.firewall.allowedUDPPorts = [ 53 ];
  networking.firewall.allowedTCPPorts = [ 53 ];

  # This is set implicitely and we're unable to change this explicitely
  #networking.networkmanager.dns = "unbound";
  networking.networkmanager.dns = lib.mkForce "none";

}
