{ config, pkgs, lib, ... }:
let
  secrets = (import ../../../secrets/secrets.nix);
  cfg = config.my.wireguardClient;
  endpoint = cfg.serverEndpoint + ":" + builtins.toString cfg.serverPort;
in
{
  options.my.wireguardClient = {
    enable = lib.mkEnableOption "";
    disableOnBoot = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    provisionWireguard = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    clientAddress = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    serverEndpoint = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    serverPort = lib.mkOption {
      type = lib.types.int;
      default = 51820;
    };
    serverDns = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    allowedIPs = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    clientPrivateKeyFile = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    serverPublicKey = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      networking.wg-quick.interfaces = {
        wg0 = {

          # https://lists.zx2c4.com/pipermail/wireguard/2017-May/001406.html
          # https://lists.zx2c4.com/pipermail/wireguard/2017-May/001407.html
          # The MTU defined below was never used but instead MSS Clamping
          # in OpenWRT was activated on zone 'lan' in the firewall:
          # 1. add "option mtu_fix '1'" in /etc/config/firewall
          # 2. service firewall restart

          # Found the clue about MTU here:
          # https://www.reddit.com/r/WireGuard/comments/cy13jt/tls_handshake_errors_behind_wireguard_vpn/eyp8mp8/

          #mtu = 1420;

          address = [
            cfg.clientAddress
            #"fd42:42:42::2/64"
          ];
          dns = [
            cfg.serverDns
            #"fd42:42:42::1"
          ];
          peers = [{
            allowedIPs = [
              cfg.allowedIPs
              #"::/0"
            ];

            endpoint = cfg.serverEndpoint + ":" + builtins.toString cfg.serverPort;

            publicKey = cfg.serverPublicKey;#;
            persistentKeepalive = 25;
          }];

          privateKeyFile = cfg.clientPrivateKeyFile; #"/persist/secrets/ursa/wg/priv.key";

          # Killswitch as per
          # https://git.zx2c4.com/wireguard-tools/about/src/man/wg-quick.8

          # Doesn't work for VMs which is communicating over a bridge with the host

          #postUp  = "${pkgs.iptables}/bin/iptables -I OUTPUT ! -o wg0 -m mark ! --mark $(${pkgs.wireguard}/bin/wg show wg0 fwmark) -m addrtype ! --dst-type LOCAL -j REJECT";
          #preDown = "${pkgs.iptables}/bin/iptables -D OUTPUT ! -o wg0 -m mark ! --mark $(${pkgs.wireguard}/bin/wg show wg0 fwmark) -m addrtype ! --dst-type LOCAL -j REJECT";
        };
      };

      systemd.services.wg-quick-wg0.wants = [ "sshd.service" ];
      #systemd.services.wg-quick-wg0.after = [ "network-online.target" ];
      systemd.services.wg-quick-wg0.before = [ "sshd.service" ];
      #systemd.services.sshd.after = [ "wg-quick-wg0.service" ];
    }

    (lib.mkIf cfg.disableOnBoot {
      systemd.services.wg-quick-wg0.wantedBy = lib.mkForce [ ];
    })

    (lib.mkIf (cfg.provisionWireguard == false) {
      services.openssh.listenAddresses = [
        {
          addr = cfg.clientAddress;
          port = secrets.ssh.port;
        }
      ];
    })
  ]);
}
