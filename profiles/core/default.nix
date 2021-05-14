{ config, pkgs, lib, ... }:

{
  imports = [
    ./zsh.nix
    ./tmux.nix
    ../../users/kraem.nix
    ../../overlays/neovim.nix
  ];

  boot.cleanTmpDir = true;

  users.mutableUsers = false;

  # Select internationalisation properties.
  console.font = "Lat2-Terminus16";
  i18n = {
    defaultLocale = "en_GB.UTF-8";
  };

  time.timeZone = "Europe/Stockholm";

  documentation.nixos.enable = true;

  nix = {
    package = pkgs.nixFlakes;
    nixPath = [
      "nixpkgs=${pkgs.path}"
    ];
    extraOptions = ''
      builders-use-substitutes = true
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
    ];
  };

  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = with pkgs; [
    direnv
    exa
    fd
    fzf
    git
    git-crypt
    gotop
    htop
    libxml2
    lsof
    neovim
    ripgrep
    rsync
    sshfs
    tmux
    tree
    pv
  ];

  home-manager = {
    useGlobalPkgs = true;
  };
}
