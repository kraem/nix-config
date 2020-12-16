{ config, pkgs, ... }:

{
  imports = [
    ./graphical
    ./git.nix
    ./email.nix
  ];

  services.lorri.enable = true;

  users.users.kraem = {
    extraGroups = [
      "fuse"
      "systemd-journal"
      "networkmanager"
      "syncthing"
      "audio"
      "video"
      "docker"
      "input"
      "kvm"
      "openvpn"
      "wireshark"
      "backup"
    ];
  };

  environment.systemPackages = with pkgs; [
    acpi
    aspell
    aspellDicts.en
    aspellDicts.sv
    cpufrequtils
    direnv
    ghc
    gnupg
    gopass
    libinput-gestures
    hunspell
    hunspellDicts.en-gb-ise
    hunspellDicts.sv-se
    neofetch
    pandoc
    ripgrep-all
    usbutils
    usbguard
    firefox

    bat
    bind
    docker
    docker-compose
    fish
    file
    gcc
    gnumake
    go
    jq
    killall
    lm_sensors
    niv
    pkg-config
    python3
    sshuttle
    wget
    wireguard
    #wkhtmltopdf
  ];

  programs = {
    nm-applet.enable = true;
  };

  sound.enable = true;
  # Using pure ALSA
  # https://discourse.nixos.org/t/cant-get-alsa-nixos-working/644
  #sound.extraConfig = ''
  #  defaults.pcm.!card "PCH"
  #  defaults.ctl.!card "PCH"
  #'';

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  nixpkgs = {
    config.pulseaudio = true;
  };

  location.provider = "geoclue2";

  environment.etc."xdg/user-dirs.conf".text = ''
    XDG_DESKTOP_DIR="$HOME/desktop"
    XDG_DOWNLOAD_DIR="$HOME/downloads"
    XDG_TEMPLATES_DIR="$HOME/system/templates"
    XDG_PUBLICSHARE_DIR="$HOME/system/public"
    XDG_DOCUMENTS_DIR="$HOME/documents"
    XDG_MUSIC_DIR="$HOME/media/music"
    XDG_PICTURES_DIR="$HOME/media/photos"
    XDG_VIDEOS_DIR="$HOME/media/video"
  '';
}
