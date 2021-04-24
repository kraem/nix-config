{ config, pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    dunst
  ];
  home-manager.users.kraem = { ... }: {
    services.dunst = {
      enable = true;
      settings = {
          global = {
          max_icon_size = 16;
          geometry = "500x10-10+35";
          format="<b>%s</b>\\n%b";
        };
      };
    };
  };
}
