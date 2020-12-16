{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    docker
    docker-compose
  ];

  virtualisation.docker.enable = true;

  # Because company VPN operates on 172.17.x.x
  # --bip is for the default bridge `docker0` CIDR range
  # --default-address-pool is the CIDR range which `docker-compose` uses for example
  virtualisation.docker.extraOptions = "--bip=\"172.26.0.1/16\" --default-address-pool=\"base=172.30.0.0/16,size=24\" --ipv6=false";

  # To make docker containers unavailable to the otuside
  # Otherwise the docker daemon opens the ports in iptables
  # This breaks NATing of the containers.
  # It is better to define networking.firewall.extraCommands
  # to close everything down except localhost e.g.
  #virtualisation.docker.extraOptions = "--iptables=false";

  # Block all connections to docker containers except from localhost
  # https://docs.docker.com/network/iptables/
  # This doesn't work as the DOCKER-USER chain isn't added before this
  # command is executed
  #networking.firewall.extraCommands = ''
  #  iptables -I DOCKER-USER ! -s 127.0.0.1 -j DROP
  #'';

  # This solution is probably the most elegant
  systemd.services.docker = {
    path = [ pkgs.iptables ];
    serviceConfig = {
      #ExecStartPost = "${pkgs.iptables}/bin/iptables -I DOCKER-USER -i ext_if ! -s 127.0.0.1 -j DROP";
      ExecStartPost = "${pkgs.iptables}/bin/iptables -I DOCKER-USER -i ext_if -m state --state ESTABLISHED,RELATED -j ACCEPT";

      TasksMax = "infinity";
    };
  };

}
