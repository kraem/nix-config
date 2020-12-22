{ config, pkgs, inputs, ... }:

let
  dotfiles = inputs.dotfiles;
in

{
  services = {
    xserver = {
      # Needed by displayManager.lightdm.greeters.mini
      displayManager.defaultSession = "none+bspwm";
      windowManager.bspwm.enable = true;
    };
  };

  home-manager.users.kraem = { ... }: {
    xdg.configFile."bspwm/bspwmrc".source = (dotfiles + "/bspwm/bspwmrc");
    xdg.configFile."sxhkd/sxhkdrc".source = (dotfiles + "/sxhkd/sxhkdrc");
  };

  nixpkgs.overlays = [
    (self: super: {
      polybar = super.polybar.override { i3Support = true; pulseSupport = true; };
    })
  ];

  environment.systemPackages = with pkgs; [
    polybar
    sxhkd
  ];
}
