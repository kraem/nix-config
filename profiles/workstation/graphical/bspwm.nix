{ config, pkgs, inputs, ... }:
let
  dotfiles = inputs.dotfiles;
in
{
  services = {
    xserver = {
      # Needed by displayManager.lightdm.greeters.mini
      displayManager.defaultSession = "none+bspwm";
      # sxhkd is started automatically with nixos bspwm module..
      # https://github.com/NixOS/nixpkgs/blob/6ca121a4793ced5279e26f0d51c2d08bf21799a3/nixos/modules/services/x11/window-managers/bspwm.nix
      windowManager.bspwm.enable = true;
    };
  };

  home-manager.users.kraem = { ... }: {
    xdg.configFile."bspwm/bspwmrc".source = (dotfiles + "/bspwm/bspwmrc");
    xdg.configFile."sxhkd/sxhkdrc".source = (dotfiles + "/sxhkd/sxhkdrc");
    services.sxhkd = {
      #enable = false;
      #extraOptions = [
      #  "-c /home/kraem/.config/sxhkd/sxhkdrc"
      #];
      #extraConfig = (dotfiles + "sxhkd/sxhkdrc");
    };
  };

  environment.systemPackages = with pkgs; [
    sxhkd
  ];
}
