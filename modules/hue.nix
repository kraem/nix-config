{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    hueadm
  ];

}
