{ config, pkgs, inputs, ... }:
let
  dotfiles = inputs.dotfiles;
in
{
  imports = [
    ./xorg.nix
    ./bspwm.nix
    ./polybar.nix
    ./dunst.nix
    ./alacritty.nix
    ./chromium.nix
    ./firefox.nix
    ./thunar.nix
    ./libinput-gestures.nix
  ];
}
