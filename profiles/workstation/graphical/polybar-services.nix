{ config, pkgs, ... }:
# TODO make module out of this
let
  wgServiceName = "wg-observer";
in
{
  systemd = {
    timers = {
      "${wgServiceName}" = {
        wantedBy = [ "timers.target" ];
        partOf = [ "${wgServiceName}.service" ];
        wants = [ "network.target" "wg-quick-w0.service" ];
        timerConfig.OnCalendar = "*:*:0/1";
        timerConfig.Persistent = "true";
        enable = true;
      };
    };

    services = {
      "${wgServiceName}" = {
        serviceConfig = {
          Type = "oneshot";
          # TODO introduced 210503
          # https://github.com/systemd/systemd/pull/19050
          # we need to bump systemd
          LogLevelMax = "notice";
        };
        script = ''
          # bug in polybar
          # https://github.com/polybar/polybar/issues/504
          if [[ $(${pkgs.wireguard}/bin/wg | ${pkgs.ripgrep}/bin/rg interface) ]];then
            ${pkgs.wireguard}/bin/wg | ${pkgs.ripgrep}/bin/rg interface | ${pkgs.coreutils}/bin/cut -d" " -f2 > /tmp/wg-observer
          else
            echo "" > /tmp/wg-observer
          fi
        '';
        path = [
        ];
        enable = true;
      };
    };
  };
}
