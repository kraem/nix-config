{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    awslogs
    awscli
  ];

}
