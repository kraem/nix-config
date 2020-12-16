{ config, pkgs, ... }:

{

  services.dbus.packages = [ pkgs.dunst ];

  systemd = {

    # https://gitlab.com/xaverdh/my-nixos-config/-/blob/master/modules/dunst.nix
    user.services.dunst = {
      # [ "" ... ] is needed to overwrite the ExecStart directive from the upstream service file
      serviceConfig.ExecStart = [ "" "${pkgs.dunst}/bin/dunst" ];
      enable = true;
    };

    packages = [ pkgs.dunst ];

    #user.services.desktop-batterynotification.serviceConfig.ExecStart = [ "" "${pkgs.libnotify}/bin/notify-send hello" ];
    user.services.desktop-batterynotification = {
      script = ''
        /home/kraem/bin/batterynotification/battery-notification-systemd.sh
      '';
      path = [ pkgs.bash pkgs.which pkgs.acpi pkgs.libnotify ];
    };

    user.timers.desktop-batterynotification = {
      wantedBy = [ "timers.target" "default.target" ];
      partOf = [ "desktop-batterynotification.service" ];
      timerConfig.OnCalendar = "*:*:0/30";
      timerConfig.Persistent = "true";
    };

    timers = {

      desktop-pscircle = {
        wantedBy = [ "timers.target" ];
        partOf = [ "desktop-pscircle.service" ];
        timerConfig.OnCalendar = "*:*:0/15";
        timerConfig.Persistent = "true";
        enable = false;
      };

      desktop-batterynotification = {
        wantedBy = [ "timers.target" ];
        partOf = [ "desktop-batterynotification.service" ];
        timerConfig.OnCalendar = "*:*:0/30";
        timerConfig.Persistent = "true";
        enable = false;
      };

      mbsync = {
        wantedBy = [ "timers.target" ];
        partOf = [ "mbsync.service" ];
        timerConfig.OnCalendar = "*:0,5,10,15,20,25,30,35,40,45,50,55";
        timerConfig.Persistent = "true";
        enable = false;
      };

    };

    services = {

      reload-broadcom-drivers = {
        serviceConfig = {
          Type = "oneshot";
        };
        after = [
          "suspend.target"
          "hibernate.target"
          "hybrid-sleep.target"
          "suspend-then-hibernate.target"
        ];
        script = ''
          modprobe -r brcmfmac && modprobe brcmfmac && systemctl restart wpa_supplicant.service
        '';
        path = [ pkgs.kmod pkgs.systemd ];
        enable = true;
      };

      desktop-lockonlidclose = {
        serviceConfig = {
          User = "kraem";
          Type = "forking";
          Restart = "on-failure";
        };
        before = [ "sleep.target" ];
        wantedBy = [ "sleep.target" ];
        environment = { DISPLAY = ":0"; };
        # `sleep` below explained here
        # https://wiki.archlinux.org/index.php/Power_management#Sleep_hooks
        script = ''
          /home/kraem/bin/xautolock/xautolock.sh
          sleep 1
        '';
        path = [ pkgs.coreutils pkgs.bash pkgs.xautolock pkgs.i3lock ];
        enable = true;
      };

      desktop-libinput-gestures = {
        serviceConfig = {
          User = "kraem";
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

      # following script from https://faq.i3wm.org/question/1730/warning-popup-when-battery-very-low.1.html

      desktop-batterynotification = {
        serviceConfig = {
          User = "kraem";
          Type = "forking";
        };
        after = [ "graphical.target" ];
        environment = {
          DISPLAY = ":0";
        };
        script = ''
          /home/kraem/bin/batterynotification/battery-notification-systemd.sh
        '';
        path = [ pkgs.bash pkgs.which pkgs.acpi pkgs.libnotify ];
        enable = false;
      };

      desktop-pscircle = {
        serviceConfig = {
          User = "kraem";
          Type = "forking";
        };
        after = [ "graphical.target" ];
        environment = {
          DISPLAY = ":0";
        };
        script = ''
          /home/kraem/bin/pscircle/pscircle-systemd.sh > /dev/null
        '';
        path = [ pkgs.bash pkgs.pscircle pkgs.feh ];
        enable = true;
      };

      mbsync = {
        serviceConfig = {
          User = "kraem";
          Type = "oneshot";
        };
        after = [ "network.target" ];
        script = ''
          mbsync -a
        '';
        path = [ pkgs.isync ];
        enable = false;
      };

    };

  };

}
