{ config, pkgs, lib, ... }:
let
  secrets = (import ../../../secrets/secrets.nix);
  cfg = config.my.wireguardServer;
in
{
  options.my.wireguardServer = {
    enable = lib.mkEnableOption "";
    serverExternalInterface = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    serverListenPort = lib.mkOption {
      type = lib.types.int;
      default = 51820;
    };
    serverPrivateKeyFile = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
  };

  config = lib.mkIf cfg.enable
    {
      # enable NAT
      networking.nat.enable = true;
      networking.nat.externalInterface = cfg.serverExternalInterface;
      networking.nat.internalInterfaces = [ "wg0" ];
      networking.firewall = {
        allowedUDPPorts = [ cfg.serverListenPort ];
      };

      networking.wireguard.interfaces = {
        wg0 = {
          # Determines the IP address and subnet of the server's end of the tunnel interface.
          ips = [
            secrets.hosts.lb1.domain
            #"fd42:42:42::1/64"
          ];

          listenPort = cfg.serverListenPort;

          # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
          # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
          postSetup = ''
            ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.0.0/32 -o ${cfg.serverExternalInterface} -j MASQUERADE
          '';

          postShutdown = ''
            ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.0.0/32 -o ${cfg.serverExternalInterface} -j MASQUERADE
          '';

          privateKeyFile = cfg.serverPrivateKeyFile;

          peers = [
            { # ursa
              publicKey = secrets.wireguard.pubKeys.ursa;
              allowedIPs = [
                secrets.hosts.ursa.domain
                #"fd42:42:42::2/64"
              ];
            }
            { # frigate
              publicKey = secrets.wireguard.pubKeys.frigate;
              allowedIPs = [
                secrets.hosts.frigate.domain
                #"fd42:42:42::2/64"
              ];
            }
            { # git
              publicKey = secrets.wireguard.pubKeys.git;
              allowedIPs = [
                secrets.hosts.git.domain
                #"fd42:42:42::2/64"
              ];
            }
            { # synapse
              publicKey = secrets.wireguard.pubKeys.synapse;
              allowedIPs = [
                secrets.hosts.synapse.domain
                #"fd42:42:42::2/64"
              ];
            }
          ];
        };
      };
    };
}
