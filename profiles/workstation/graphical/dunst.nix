{ config, pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    dunst
  ];
  home-manager.users.kraem = { ... }: {
    services.dunst = {
      enable = true;
    };
  };
}
