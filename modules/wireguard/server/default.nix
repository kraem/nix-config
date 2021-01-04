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
            "10.0.0.1/24"
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
              # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
              allowedIPs = [
                "10.0.0.2/32"
                #"fd42:42:42::2/64"
              ];
            }
          ];
        };
      };
    };
}
