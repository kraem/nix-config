{ config, pkgs, inputs, ... }:
{
  home-manager.users.kraem = { ... }: {
    services.dunst = {
      enable = true;
    };
  };
}
