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
    # TODO: leaving this until all hosts are using impermanence
    # TODO: assert
    syncthingDir = lib.mkOption {
      type = types.path;
      default = "";
    };
  };

  config = mkIf cfg.enable

  {

    users.users.kraem.extraGroups = [ "syncthing" ];

    systemd.services.syncthing.serviceConfig.UMask = "007";

    services = {
      syncthing = {
        enable = true;
        openDefaultPorts = true;
        systemService = true;
        configDir = config.services.syncthing.dataDir + "/config";
        dataDir = cfg.syncthingDir;
        declarative = {
          devices = {
            ursa = {
              id = cfg.syncthingIDs.ursa;
            };
            lb1 = {
              id = cfg.syncthingIDs.lb1;
            };
            frigate = {
              id = cfg.syncthingIDs.frigate;
            };
          };
          folders.tmp = {
            devices =  [ "ursa" "lb1" "frigate" ];
            path = config.services.syncthing.dataDir + "/tmp";
          };
          folders.notes = {
            devices =  [ "ursa" "lb1" "frigate" ];
            path = config.services.syncthing.dataDir + "/notes";
          };
          folders.documents = {
            devices =  [ "ursa" "lb1" "frigate" ];
            path = config.services.syncthing.dataDir + "/documents";
          };
          folders.bin = {
            devices =  [ "ursa" "lb1" "frigate" ];
            path = config.services.syncthing.dataDir + "/bin";
          };
        };
      };
    };
  };
}
