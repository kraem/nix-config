{ config, pkgs, inputs, ... }:
let
  dotfiles = inputs.dotfiles;
in
{
  imports = [
    ./xorg.nix
    ./bspwm.nix
    ./polybar.nix
    ./chromium.nix
    ./firefox.nix
    ./thunar.nix
  ];

  # TODO export to own module
  home-manager.users.kraem = { ... }: {
    xdg.configFile."alacritty/alacritty.yml".source = (dotfiles + "/alacritty/alacritty.yml");
  };
}
