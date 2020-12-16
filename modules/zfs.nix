{ config, pkgs, ... }:

{

  services = {

    zfs = {
      autoScrub.enable = true;
      autoScrub.interval = "weekly";

      # Don't forget to `zfs set com.sun:auto-snapshot=true <pool>/<fs>`
      autoSnapshot = {
        enable = true;
        frequent = 8;
        hourly = 24;
        daily = 21;
        weekly = 8;
        monthly = 6;
      };
    };

  };

}
