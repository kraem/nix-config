{ config, pkgs, inputs, ... }:
let
  # TODO
  # - clean
  # - fix conditionals (extract to workstation module)
  wifiModule = (if config.networking.hostName == "ursa" then "wlp8s0" else "wlp3s0");
  fontSize = (if config.networking.hostName == "ursa" then "12" else "13");
  barHeight = (if config.networking.hostName == "ursa" then "22" else "33");

  polybarConfig = ''
    [colors]
    background = #222222
    background-alt = #444
    foreground = #FFFFFF
    foreground-alt = #555
    primary = #ff
    secondary = #e60053
    alert = #bd2c40

    [settings]
    screenchange-reload = true

    [global/wm]
    margin-top = 0
    margin-bottom = 0

    [bar/top]
    width = 100%
    height = ${barHeight}
    offset-x = 0%
    offset-y = 0%
    radius = 0
    fixed-center = true

    separator = "  "

    background = ''${colors.background}
    foreground = ''${colors.foreground}

    padding-left = 0
    padding-right = 1

    module-margin-left = 1
    module-margin-right = 1

    font-0 = Open Sans:pixelsize=${fontSize};3
    font-1 = Font Awesome 5 Free,Font Awesome 5 Free Regular:style=Regular:pixelsize=${fontSize};3
    font-2 = Font Awesome 5 Brands,Font Awesome 5 Brands Regular:style=Regular:pixelsize=${fontSize};3
    font-3 = Font Awesome 5 Free,Font Awesome 5 Free Solid:style=Solid:pixelsize=${fontSize};3

    modules-left = bspwm
    modules-center = date
    modules-right = wlan pulseaudio battery

    tray-position = right

    cursor-click = pointer
    cursor-scroll = ns-resize

    # Solves issue when polybar is rendered on top
    # of nodes in full screen.
    # Also has suggestion on how to do it with lemonbar.
    # https://github.com/baskerville/bspwm/issues/857
    wm-restack = bspwm

    [module/bspwm]
    type = internal/bspwm

    format = <label-state> <label-mode>

    label-monocle = M
    label-monocle-foreground = #ffffff
    label-separator-padding = 1

    label-focused = %name%
    label-focused-background = ''${colors.background-alt}
    label-focused-padding = 1

    label-occupied = %name%
    label-occupied-padding = 1

    label-urgent = %index%!
    label-urgent-background = ''${colors.alert}
    label-urgent-padding = 1

    label-empty =
    label-empty-foreground = ''${colors.foreground-alt}
    label-empty-padding = 1

    [module/wlan]
    type = internal/network
    interface = ${wifiModule}
    interval = 3.0

    format-connected =   <label-connected>
    label-connected = %essid%

    format-disconnected =

    ramp-signal-foreground = ''${colors.foreground-alt}

    [module/date]
    type = internal/date
    interval = 1

    date = %Y %m %d

    time = %H %M %S

    format-prefix-foreground = ''${colors.foreground-alt}

    label = %date%   %time%

    [module/pulseaudio]
    type = internal/pulseaudio

    format-volume =   <label-volume>
    format-muted =   <label-muted>

    label-volume = %percentage%%
    label-volume-foreground = ''${root.foreground}

    label-muted = %percentage%%
    label-muted-foreground = #666

    [module/battery]
    type = internal/battery
    battery = BAT0
    adapter = ADP1
    full-at = 98

    format-charging =   <label-charging>
    format-discharging =   <label-discharging>
    format-full =  <label-full>

    label-charging = %percentage%%
    label-discharging = %percentage%%
    label-full = %percentage%%
  '';
in
{
  home-manager.users.kraem = { ... }: {
    services.polybar = {
      enable = true;
      package = pkgs.polybar.override { pulseSupport = true; };
      extraConfig = polybarConfig;
      script = "polybar top &";
    };
  };
}
