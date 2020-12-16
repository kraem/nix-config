{ config, pkgs, ... }:

{

  hardware.facetimehd.enable = true;

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  imports = [
    ./bluetooth
  ];

}
