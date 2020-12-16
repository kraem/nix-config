{ config, pkgs, ... }:

{
  networking.networkmanager.wifi.backend = "wpa_supplicant";
  networking.networkmanager.enableStrongSwan = true;
  environment.systemPackages = [
    libinput-gestures
  ];
}
