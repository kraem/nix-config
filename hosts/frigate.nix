# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  secrets = (import ../secrets/secrets.nix);
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ../hardware/frigate.nix
      ../hardware/frigate-extra.nix

      ../profiles/core
      ../profiles/workstation
      ../modules/zfs.nix

      ../modules/network.nix
      ../modules/morph.nix
      ../modules/sshd.nix

      ../modules/agents.nix
      ../overlays/neovim.nix

      ../modules/syncthing
    ];

  # TODO: leave syncthingDir as the default syncthing module dir
  # and use impermanence instead
  my.syncthing = {
    enable = true;
    syncthingDir = "/var/lib/syncthing";
    syncthingIDs = secrets.syncthingIDs;
  };

  # TODO: move to persistence
  systemd.tmpfiles.rules = [
    "L ${config.users.users.kraem.home}/notes 770 syncthing syncthing - ${config.my.syncthing.syncthingDir}/notes"
  ];

  environment.persistence."/persist" = {
    directories = [
      "/var/log"
      "/var/lib/syncthing"

      "/etc/NetworkManager/system-connections"
      "/etc/ssh"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  hardware.enableAllFirmware = true;

  nixpkgs.config.allowUnfree = true;

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/local/root@blank
  '';

  # TODO: extract these
  systemd.services.lockonlidclose =
       {
         before = [ "suspend.target" ];
         wantedBy = [ "suspend.target" ];
         script =
           ''
	     set -eu
             echo locking
             xautolock -locknow
             echo locking done
           '';
	 postStart = "sleep 1";
         environment = { DISPLAY = ":0"; };
         serviceConfig.Type = "forking";
	 # FIXME: modularise this with home-manager?
         serviceConfig.User = "kraem";
         path = [ pkgs.coreutils pkgs.bash pkgs.xautolock pkgs.i3lock ];
       };

  systemd.services.disablewakeups =
       { after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
         script =
           ''
	     set -eu
             for d in $(cat /proc/acpi/wakeup | sed 1d | grep enabled | grep -v LID0 | cut -d' ' -f1); do
               echo $d > /proc/acpi/wakeup
             done
           '';
         serviceConfig.Type = "oneshot";
         path = [ pkgs.coreutils pkgs.bash ];
       };

  powerManagement.powerDownCommands = ''
    ${pkgs.coreutils}/bin/echo unloading brcmfmac
    ${pkgs.kmod}/bin/lsmod | ${pkgs.gnugrep}/bin/grep -q "^brcmfmac" && ${pkgs.kmod}/bin/rmmod -f -v brcmfmac
    ${pkgs.coreutils}/bin/echo unloading bluetooth
    ${pkgs.kmod}/bin/lsmod | ${pkgs.gnugrep}/bin/grep -q "^blueooth" && ${pkgs.kmod}/bin/rmmod -f -v bluetooth
    ${pkgs.coreutils}/bin/echo done
  '';
  powerManagement.resumeCommands = ''
    ${pkgs.coreutils}/bin/echo loading brcmfmac
    ${pkgs.kmod}/bin/modprobe -v brcmfmac
    ${pkgs.coreutils}/bin/echo loading bluetooth
    ${pkgs.kmod}/bin/modprobe -v bluetooth
    ${pkgs.coreutils}/bin/echo done
  '';

  powerManagement = {
    enable = true;
    cpufreq.max = 2400000;
    cpuFreqGovernor = "performance";
  };

  services = {
    # TODO: research HoldOffTimeoutSec more
    logind.extraConfig = ''
      HandlePowerKey=ignore
      HoldoffTimeoutSec=5s
    '';
    #logind.lidSwitch = "suspend";
  };

  services.openssh = {
    hostKeys = [
      {
        path = "/persist/etc/ssh/frigate_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.efi.canTouchEfiVariables = true;

  #boot.loader.systemd-boot.consoleMode = "max";

  #boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  #boot.extraModulePackages = [ pkgs.linuxPackages.v4l2loopback ];

  #networking.enableB43Firmware = true;

  networking.hostName = "frigate";
  networking.hostId = "3ac01c6c";

  networking.useDHCP = false;
  networking.interfaces.wlp3s0.useDHCP = true;

  services.tlp.enable = false;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  users.defaultUserShell = pkgs.zsh;

  services = {

    xserver = {
      videoDrivers = [ "intel" ];
    };

    mbpfan.enable = true;

    usbguard.enable = true;
    usbguard.rules = ''
      allow id 1d6b:0002 serial "0000:00:14.0" name "xHCI Host Controller" hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" parent-hash "rV9bfLq7c2eA4tYjVjwO4bxhm+y6GgZpl9J60L0fBkY=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0003 serial "0000:00:14.0" name "xHCI Host Controller" hash "3Wo3XWDgen1hD5xM3PSNl3P98kLp1RUTgGQ5HSxtf8k=" parent-hash "rV9bfLq7c2eA4tYjVjwO4bxhm+y6GgZpl9J60L0fBkY=" with-interface 09:00:00 with-connect-type ""
      allow id 05ac:8290 serial "" name "Bluetooth USB Host Controller" hash "wlK/NEZuUQjXJ6Jhu3hCfx+Pf9BGpXP/mpdYhtUHn/E=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" via-port "1-3" with-interface { 03:01:01 03:01:02 ff:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 ff:ff:ff fe:01:01 } with-connect-type "hardwired"
      allow id 05ac:0273 serial "D3H5352D851FTV3AB1PS" name "Apple Internal Keyboard / Trackpad" hash "Zw9lULWHbVEeVGyLLSmBcyqLifj2yOvkBX7wjP9kdEA=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" with-interface { 03:00:00 03:01:01 03:01:02 03:00:00 03:00:00 } with-connect-type "hardwired"
      allow id 05ac:8406 serial "000000000820" name "Card Reader" hash "ZAFLn0nkPb4JITS73A0q9buo3ODOvh7XSNDhnlrUFVk=" parent-hash "3Wo3XWDgen1hD5xM3PSNl3P98kLp1RUTgGQ5HSxtf8k=" with-interface 08:06:50 with-connect-type "hardwired"
      allow id fc51:0058 serial "0" name "Lily58" hash "gAYK4i//Ibcu8KoWpibtdAI1+lDNyRNTn03Tyy1cPoo=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" with-interface 03:01:01 with-connect-type "hotplug"
      allow id 05ac:12a8 serial "099bba55f1be70d22f8d93b54d30761b70cddd41" name "iPhone" hash "DpWH3YCbEV6LQXC2T3L9+xqenKL1M+J9PL/2kklDxWg=" parent-hash "jEP/6WzviqdJ5VSeTUY8PatCNBKeaREvo2OqdplND/o=" with-interface { 06:01:01 01:01:00 01:02:00 01:02:00 03:00:00 06:01:01 ff:fe:02 06:01:01 ff:fe:02 ff:fd:01 ff:fd:01 ff:fd:01 } with-connect-type "hotplug"
    '';

  };

  hardware.cpu.intel.updateMicrocode = true;

  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;
  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.03"; # Did you read the comment?

}
