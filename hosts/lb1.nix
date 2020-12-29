# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  secrets = (import ../secrets/secrets.nix);
in

{
  imports =
    [
      # Include the results of the hardware scan.
      ../hardware/lb1.nix

      ../modules/morph.nix
      ../modules/sshd.nix

      ../profiles/core

      ../modules/network.nix

      ../modules/zfs.nix

      ../modules/syncthing
      ../modules/synapse/synapse-backup-fetcher.nix

      ../modules/rar-mount.nix
      ../modules/weechat.nix
      ../modules/hue.nix
      ../modules/docker.nix

    ];

  systemd.tmpfiles.rules = [
    "d /secrets/ 0755 root root -"
  ];

  my.syncthing = {
    enable = true;
    syncthingDir = "/data/enc/syncthing";
    syncthingIDs = secrets.syncthingIDs;
  };

  services.jellyfin = {
    enable = true;
    user = "kraem";
    group = "users";
  };
  networking.firewall.allowedTCPPorts = [ 8096 ];

  # These were found with `sensors-detect`
  #boot.kernelModules = [ "coretemp" "jc42" "w83627ehf" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/disk/by-id/wwn-0x50026b7682b6fa1a"; # or "nodev" for efi only

  boot.initrd.luks.devices = {
    root = { device = "/dev/disk/by-uuid/c7504181-7b78-49be-8f41-a17f82f86327"; };
    swap = { device = "/dev/disk/by-uuid/06b414d1-2559-4b98-98cb-9807b3901491"; };
  };

  # This is used if we don't want NixOS handling the mounting of the ZFS pools
  # and datasets.
  # The ZFS property "mountpoint" on the pool/dataset needs to be set to the dir
  # where it should be mounted.
  #
  # This is now defined in hardware-configuration.nix with fileSystems."/data" and
  # "mountpoint" set to 'legacy' on the pool and/or dataset. This makes it possible for
  # NixOS to mount the pools/datasets with systemd-generator (generating fstab entries
  # which can be controlled through systemd-units instead)
  #boot.zfs.extraPools = [
  #  "data"
  #];

  networking.hostName = "lb1"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp4s0.useDHCP = true;
  networking.interfaces.enp5s0.useDHCP = true;

  networking.hostId = "e36c81ad";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  #i18n = {
  #  consoleFont = "Lat2-Terminus16";
  #  consoleKeyMap = "sv-latin1";
  #  defaultLocale = "en_US.UTF-8";
  #};

  # Set your time zone.
  #time.timeZone = "Europe/Amsterdam";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}
