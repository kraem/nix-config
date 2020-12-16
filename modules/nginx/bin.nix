{ pkgs, config, lib, ... }:

let
  acmeEmail = (import ../../secrets.nix).email.gmailFull;

  fqdn =
    let
      join = hostName: domain:
        hostName + lib.optionalString (domain != null) ".${domain}";
    in
    join config.networking.hostName config.networking.domain;
in

{

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.acme.email = acmeEmail;
  security.acme.acceptTerms = true;

  systemd.tmpfiles.rules = [
    "d /dump/ 0711 nginx nginx -"
    "d /img/ 0711 nginx nginx -"
  ];

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    virtualHosts = {
      "${config.networking.domain}" = {

        enableACME = true;
        forceSSL = true;

        locations."/img/" = {
          alias = "/img/";
          extraConfig = ''
            #autoindex on;
          '';
        };

        locations."/tmp/" = {
          alias = "/dump/";
          extraConfig = ''
            #autoindex on;
          '';
        };
      };

      ${fqdn} = {
        enableACME = true;
        forceSSL = true;
        locations."/".extraConfig = ''
          return 404;
        '';
      };
    };
  };
}
