{ config, pkgs, lib, ... }:

{
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "wpa_supplicant";
  networking.networkmanager.enableStrongSwan = true;
  networking.dhcpcd.enable = false;
  networking.networkmanager.dhcp = "internal";
  #networking.networkmanager.logLevel = "DEBUG";

  # fix for wait-olnine as the original `nm-online -s -q` doesn't work
  # `nm-online works though.. `-t 5` just defines the timeout

  # -s | --wait-for-startup
  #  Wait for NetworkManager startup to complete, rather than waiting for network
  #  connectivity specifically. Startup is considered complete once NetworkManager has
  #  activated (or attempted to activate) every auto-activate connection which is
  #  available given the current network state. This corresponds to the moment when
  #  NetworkManager logs "startup complete". This mode is generally only useful at boot
  #  time. After startup has completed, nm-online -s will just return immediately,
  #  regardless of the current network state.

  # to override ExecStart we need to define it as an empty string first..
  # https://github.com/NixOS/nixpkgs/issues/63703#issuecomment-504836857

  #systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart = [
  #  ""
  #  "${pkgs.networkmanager}/bin/nm-online -q -t 5"
  #];
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

}
