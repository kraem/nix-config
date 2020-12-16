{ config, pkgs, ... }:

let
  dotfiles = ((import ../../nix).dotfiles);
in

{
  environment.systemPackages = with pkgs; [
    tmux
  ];
  home-manager.users.kraem = { ... }: {
    home.file.".tmux.conf".source = (dotfiles + "/tmux/tmux.conf");
  };
}
