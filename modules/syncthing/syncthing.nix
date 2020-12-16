{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.my.syncthing;
in
{

  options.my.syncthing = {
    enable = lib.mkEnableOption "Enables Syncthing and creates data/config dirs";
    # TODO pass in as (listOf attrs)
    # and do something like (filter (n: n ? "ursa") syncthingIDs)
    syncthingIDs = lib.mkOption {
      type = types.attrs;
      default = {};
    };
    # TODO assert these
    syncthingDir = lib.mkOption {
      type = types.path;
      default = "";
    };
    cert = lib.mkOption {
      type = types.path;
      default = "";
    };
    key = lib.mkOption {
      type = types.path;
      default = "";
    };
  };

  config = mkIf cfg.enable

  {

    systemd.tmpfiles.rules = [
      "d ${cfg.syncthingDir} 0755 syncthing syncthing -"
    ];

    users.users.kraem.extraGroups = [ "syncthing" ];

    systemd.services.syncthing.serviceConfig.UMask = "007";

    services = {
      syncthing = {
        enable = true;
        openDefaultPorts = true;
        systemService = true;
        configDir = cfg.syncthingDir + "/config";
        declarative = {
          cert = cfg.cert;
          key = cfg.key;
          devices = {
            ursa = {
              id = cfg.syncthingIDs.ursa;
            };
            lb1 = {
              id = cfg.syncthingIDs.lb1;
            };
          };
          folders.tmp = {
            devices =  [ "ursa" "lb1" ];
            path = cfg.syncthingDir + "/tmp";
          };
          folders.notes = {
            devices =  [ "ursa" "lb1" ];
            path = cfg.syncthingDir + "/notes";
          };
          folders.documents = {
            devices =  [ "ursa" "lb1" ];
            path = cfg.syncthingDir + "/documents";
          };
          folders.bin = {
            devices =  [ "ursa" "lb1" ];
            path = cfg.syncthingDir + "/bin";
          };
        };
      };
    };
  };
}
