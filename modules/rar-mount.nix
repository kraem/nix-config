{ config, pkgs, ... }:
let
  user = "kraem";
  filmsRarDir = "/data/enc/media/films";
  filmsMountPoint = "/data/media-mount/films";
  seriesRarDir = "/data/enc/media/series";
  seriesMountPoint = "/data/media-mount/series";
in
{

  environment.systemPackages = with pkgs; [ rar2fs ];
  programs.fuse.userAllowOther = true;

  systemd = {

    services = {

      mount-rared-media-dir = {
        serviceConfig = {
          User = "${user}";
          Type = "forking";
        };
        after = [ "local-fs.target" "zfs-import-data.service" ];
        wantedBy = [ "multi-user.target" ];
        script = ''
          mkdir -p ${filmsMountPoint}
          mkdir -p ${seriesMountPoint}
          mount.rar2fs ${filmsRarDir} ${filmsMountPoint}
          mount.rar2fs ${seriesRarDir} ${seriesMountPoint}
        '';
        path = [ pkgs.rar2fs ];
        enable = true;

      };

    };

  };

}
