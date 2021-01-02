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

  environment.systemPackages = with pkgs; [
    sxhkd
  ];
}
