{ config, pkgs, modulesPath, lib, ... }:

{
  imports = [

      (modulesPath + "/installer/cd-dvd/installation-cd-graphical-gnome.nix")
      (modulesPath + "/installer/cd-dvd/channel.nix")
      ./profiles/core
      ./modules/sshd.nix
      ./modules/morph.nix
  ];

  services.xserver.desktopManager.gnome.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
