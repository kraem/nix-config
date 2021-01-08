{ config, pkgs, ... }:

{
  systemd.user.services.libinput-gestures = {
    serviceConfig = {
      Restart = "on-failure";
    };
    wantedBy = [ "multi-user.target" ];
    environment = {
      DISPLAY = ":0";
    };
    script = ''

      # Is it best to inline the scripts here or should we call the scripts?
      # We win a wrapping bash process if inlining
      #/home/kraem/bin/libinput-gestures/libinput-gestures.sh

      set -e

      libinput-gestures
    '';
    path = [ pkgs.bash pkgs.libinput-gestures pkgs.dbus ];
    enable = true;
  };
}
