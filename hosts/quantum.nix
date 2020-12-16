# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
    ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

  boot.kernelPackages = pkgs.linuxPackages_latest; # Let's run the newest kernel

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  powerManagement.cpufreq.max = 1200000;

  networking.hostName = "Quantum";
  networking.hostId = "4b55c5de";

  networking.firewall.allowedTCPPorts = [ 8080 ];
  #
  # https://nixos.wiki/wiki/Nvidia#static_mode
  hardware.nvidia.optimus_prime.enable = true;
  hardware.nvidia.optimus_prime.nvidiaBusId = "PCI:1:0:0";
  hardware.nvidia.optimus_prime.intelBusId = "PCI:0:2:0";
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/hardware/video/nvidia.nix#L42
  hardware.nvidia.modesetting.enable = true;

  services = {
    xserver = {
      videoDrivers = [ "intel" "nvidia" ];
    };
    mbpfan.enable = true;
  };
}
