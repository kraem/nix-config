{ config, pkgs, ... }:

{
  systemd.user.services.libinput-gestures = {
    serviceConfig = {
      Restart = "on-failure";
    };
    wantedBy = [ "graphical-session.target" ];
    environment = {
      DISPLAY = ":0";
    };
    script = ''
      set -e
      libinput-gestures
    '';
    path = [ pkgs.bash pkgs.libinput-gestures pkgs.dbus ];
    enable = true;
  };
}
