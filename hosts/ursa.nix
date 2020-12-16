# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  secrets = (import ../secrets.nix);
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ../hardware/ursa.nix
      ../hardware/ursa-extra.nix

      ../profiles/core
      ../profiles/workstation
      ../modules/zfs.nix

      ../modules/sshd.nix
      ../modules/network.nix
      ../modules/agents.nix
      ../overlays/neovim.nix

      ../modules/syncthing
    ];

  my.syncthing = {
    enable = true;
    syncthingDir = "/persist/var/lib/syncthing";
    key = "/persist/secrets/ursa/syncthing/key.pem";
    cert = "/persist/secrets/ursa/syncthing/cert.pem";
    syncthingIDs = secrets.syncthingIDs;
  };

  systemd.tmpfiles.rules = [
    "L ${config.users.users.kraem.home}/notes 770 syncthing syncthing - ${config.my.syncthing.syncthingDir}/notes"
  ];

  hardware.enableAllFirmware = true;

  nixpkgs.config.allowUnfree = true;

  services.openssh = {
    hostKeys = [
      {
        path = "/persist/etc/ssh/ursa_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };

  # for signing binary cache
  nix.extraOptions = "secret-key-files = /persist/etc/nix/key.private";

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/local/root@blank
  '';

  environment.etc = {
    "NetworkManager/system-connections" = {
      source = "/persist/etc/NetworkManager/system-connections/";
    };
    "machine-id" = {
      source = "/persist/etc/machine-id";
    };
    #"nix/nix.conf" = lib.mkForce {
    #  source = "/persist/etc/nix.conf";
    #};
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "ursa";
  networking.hostId = "61485d81";

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp9s0.useDHCP = true;
  networking.interfaces.wlp8s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  console = {
    #font = "Lat2-Terminus16";
    #keyMap = "se";
  };

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  #services.xserver.enable = true;
  #services.xserver.layout = "se";
  # services.xserver.xkbOptions = "eurosign:e";
  #services.xserver.desktopManager.gnome3.enable = true;

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.03"; # Did you read the comment?

}
