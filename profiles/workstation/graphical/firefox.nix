{ config, pkgs, ... }:

{
  # for that firefox smooth scrolling
  environment.variables = {
    MOZ_USE_XINPUT2 = "1";
  };

  environment.systemPackages = with pkgs; [
    firefox
  ];
}
