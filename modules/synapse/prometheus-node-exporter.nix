{ pkgs, config, lib, ... }:
let
  node-exporter-dashboard-json = pkgs.fetchurl {
    url =
      "https://raw.githubusercontent.com/rfrail3/grafana-dashboards/master/prometheus/node-exporter-full.json";
    sha256 = "1cgv4mr6xx79x1bxn0q6byn8j5pf3pgb0w6h09pby3692asb13w5";
  };
in
{

  environment.etc.node-exporter = {
    source = node-exporter-dashboard-json;
    target = "/grafana-dashboards/node-exporter";
  };
  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        listenAddress = "127.0.0.1";
        port = 9100;
      };
    };
    scrapeConfigs = [{
      job_name = "node_exporter";
      scrape_interval = "10s";
      metrics_path = "/metrics";
      static_configs = [{
        targets = [ "localhost:9100" ];
      }];
    }];
  };
  services.grafana = {
    provision.dashboards = [{
      name = "node-exporter";
      type = "file";
      folder = "Server";
      options.path =
        "/etc/grafana-dashboards/node-exporter";
    }];
    #provision.datasources = [{
    #  name = "node-exporter-prometheus";
    #  url = "localhost:9090";
    #  type = "prometheus";
    #}];
  };
}
