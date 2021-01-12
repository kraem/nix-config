{ pkgs, config, lib, ... }:

# skeleton from
# https://nixos.org/manual/nixos/stable/index.html#module-services-matrix-synapse
let

  secrets = (import ../../secrets/secrets.nix);

  fqdn =
    let
      join = hostName: domain:
        hostName + lib.optionalString (domain != null) ".${domain}";
    in
    join config.networking.hostName config.networking.domain;

  # fetch the grafana dashboard
  synapse-dashboard-json = pkgs.fetchurl {
    url =
      "https://raw.githubusercontent.com/matrix-org/synapse/master/contrib/grafana/synapse.json";
    sha256 = "1w0yba5fa1w18kngidx2vjjnwx43rhhn670ymrackvvsg22qgi7j";
  };

  # we can write a file to /nix/store like so:
  # index = builtins.toFile "index.html" ''content'';
  # but we don't get a root dir for that file but only /nix/store/hash-index.html
  # we can't use that with nginx server blocks, they need a root
  #
  # ^ learnt from balsoft 2020-10-22 in #nix:matrix.org
  #
  # we can also define a simple string
  # indexHtml = ''content'';
  # and later use it as in the nginx tests:
  # root = pkgs.runCommand "nginx-www-root" {} ''
  #   mkdir "$out"
  #   cat > "$out/index.html" <<EOF
  #   ${index}
  # '';
  #
  # ^ is stolen from nginx tests: https://github.com/NixOS/nixpkgs/blob/master/nixos/tests/nginx.nix#L37-L41

  # and then there's the writeTextFile which gives us a path, file and more options
  indexHtml = pkgs.writeTextFile {
    name = "index.html";
    executable = false;
    destination = "/index.html";
    text = ''
      <html>
      <head>
      <meta charset="UTF-8">
      <style>
      .center {
      position: absolute;
      margin: auto;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      }
      </style>
      </head>
      <body>
      <img
      class="center"
      src=https://upload.wikimedia.org/wikipedia/commons/a/af/Regalecus_glesne_Mexico.jpg
      >
      <img/>
      </body
      </html>
    '';
  };
  # ^ learnt from balsoft 2020-10-22 in #nix:matrix.org
  # example with someone writing a script with it:
  # https://discourse.nixos.org/t/adding-folders-and-scripts/5114/3

in
{

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # the db-name "matrix-synapse" can be changed in services.postgresql.database_name
  services.postgresql.initialScript = pkgs.writeText "synapse-init.sql" ''
    CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD ${secrets.hosts.synapse.postgresLoginPw};
    CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
      TEMPLATE template0
      LC_COLLATE = "C"
      LC_CTYPE = "C";
  '';

  # force renewing certs - not sure if this is needed actually
  # https://github.com/NixOS/nixpkgs/issues/81634
  #security.acme.validMinDays = 999;

  security.acme.email = secrets.email.gmailFull;
  security.acme.acceptTerms = true;

  services.nginx = {
    enable = true;
    # only recommendedProxySettings and recommendedGzipSettings are strictly required,
    # but the rest make sense as well
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    virtualHosts = {
      # This host section can be placed on a different host than the rest,
      # i.e. to delegate from the host being accessible as ${config.networking.domain}
      # to another host actually running the Matrix homeserver.
      "${config.networking.domain}" = {

        enableACME = true;
        forceSSL = true;

        # https://github.com/matrix-org/synapse/blob/develop/docs/reverse_proxy.md
        locations."~* ^(/_matrix|/_synapse/client)" = {
          proxyPass = "http://[::1]:8008"; # without a trailing /
        };

        # expose admin api
        #locations."~* ^\/_synapse\/admin\/v1" = {
        #  proxyPass = "http://[::1]:8008"; # without a trailing /
        #};

        # this could potentially proxy to nice website, but for now 404
        locations."/" = {
          root = indexHtml;
          #extraConfig = ''
          #  return 404
          #'';
        };

        # server delegations
        locations."= /.well-known/matrix/server".extraConfig =
          let
            # use 443 instead of the default 8448 port to unite
            # the client-server and server-server port for simplicity
            server = { "m.server" = "${fqdn}:443"; };
          in
          ''
            add_header Content-Type application/json;
            return 200 '${builtins.toJSON server}';
          '';

        # client delegations
        locations."= /.well-known/matrix/client".extraConfig =
          let
            client = {
              "m.homeserver" = { "base_url" = "https://${fqdn}"; };
              "m.identity_server" = { "base_url" = "https://vector.im"; };
            };
            # ACAO required to allow element-web on any URL to request this json file
          in
          ''
            add_header Content-Type application/json;
            add_header Access-Control-Allow-Origin *;
            return 200 '${builtins.toJSON client}';
          '';
      };

      # Reverse proxy for Matrix client-server and server-server communication
      ${fqdn} = {
        enableACME = true;
        forceSSL = true;

        # Or do a redirect instead of the 404, or whatever is appropriate for you.
        # But do not put a Matrix Web client here! See the Element web section below.
        locations."/".extraConfig = ''
          return 404;
        '';

        # forward all Matrix API calls to the synapse Matrix homeserver
        locations."/_matrix" = {
          proxyPass = "http://[::1]:8008"; # without a trailing /
        };
      };
    };
  };

  services.matrix-synapse = {
    enable = true;
    server_name = config.networking.domain;
    enable_metrics = true;
    listeners = [
      {
        port = 8008;
        bind_address = "::1";
        type = "http";
        tls = false;
        x_forwarded = true;
        resources = [{
          names = [ "client" "federation" ];
          compress = true;
        }];
      }
      {
        bind_address = "::1";
        port = 9002;
        type = "http";
        tls = false;
        x_forwarded = true;
        resources = [{
          names = [ "client" "metrics" ];
          compress = true;
        }];
      }
    ];
  };

  services.prometheus = {
    enable = true;
    scrapeConfigs = [{
      job_name = "synapse";
      scrape_interval = "10s";
      metrics_path = "/_synapse/metrics";
      static_configs = [{
        targets = [ "localhost:9002" ];
        labels = { alias = "prometheus.synapse.${secrets.hosts.synapse.pubDomain}"; };
      }];
    }];
  };

  environment.etc.synapse = {
    source = synapse-dashboard-json;
    target = "/grafana-dashboards/synapse";
  };

  services.grafana = {
    enable = true;
    addr = "127.0.0.1";
    provision.enable = true;
    provision.dashboards = [{
      name = "synapse";
      type = "file";
      options.path = #config.environment.etc.synapse.target;
        "/etc/grafana-dashboards/synapse";
    }];
    provision.datasources = [{
      name = "prometheus";
      url = "localhost:9090";
      type = "prometheus";
    }];
  };

}
