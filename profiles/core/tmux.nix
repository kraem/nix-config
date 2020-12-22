{ config, pkgs, inputs, ... }:
let
  dotfiles = inputs.dotfiles;
in
{
  environment.systemPackages = with pkgs; [
    tmux
  ];
  home-manager.users.kraem = { ... }: {
    home.file.".tmux.conf".source = dotfiles + "/tmux/tmux.conf";
  };
}
