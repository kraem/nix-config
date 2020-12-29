{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    alacritty
    #apulse
    arandr
    arc-icon-theme
    # https://github.com/NixOS/nixpkgs/pull/85253
    # https://nixos.wiki/wiki/Chromium#Enable_GPU_accelerated_video_decoding_.28VA-API.29
    # Overriding does not trigger a rebuild anymore! 🎉
    (chromium.override { enableVaapi = true; })
    deluge
    discord
    #dunst
    element-desktop
    #emacs
    # for i3blocks volume-pulseaudio blocklet
    gettext
    feh
    firefox
    font-manager
    gnome3.adwaita-icon-theme
    gnome-themes-extra
    hsetroot
    imagemagick
    libnotify
    lxappearance
    maim
    mpv
    pavucontrol
    plano-theme
    pscircle
    # For pinentry-gnome3
    #pinentry_gnome
    # Is this really needed?
    #pinentry
    rofi
    rxvt_unicode
    scrot
    slack
    spotify
    virtmanager
    vulkan-tools
    wireshark
    # for wpg --preview
    wpgtk
    xautolock
    xclip
    xdotool
    xsel
    yubikey-manager
    zathura
  ];

  xdg.icons.enable = true;

  console.useXkbConfig = true;

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      hack-font
      dejavu_fonts
      montserrat
      noto-fonts
      noto-fonts-emoji
      open-sans
      font-awesome
      roboto
      nerdfonts
    ];
  };

  services = {
    gnome3.gnome-keyring.enable = true;
    redshift.enable = true;
    xserver = {
      enable = true;
      desktopManager.xterm.enable = false;
      exportConfiguration = true;

      layout = "se";
      xkbOptions = "ctrl:nocaps";
      autoRepeatDelay = 200;
      autoRepeatInterval = 10;

      displayManager.lightdm.enable = true;
      displayManager.lightdm.greeters.mini = {
        #enable = true;
        user = "kraem";
        extraConfig = ''
          [greeter]
          show-password-label = true
          [greeter-theme]
          background-image = ""
          border-width = 1px
        '';
      };

      libinput = {
        enable = true;
        naturalScrolling = true;
        disableWhileTyping = true;
      };

      xautolock.enable = true;
      xautolock.time = 3;
      xautolock.extraOptions = [
        "-corners 0-0-"
      ];
      xautolock.locker = "${pkgs.i3lock}/bin/i3lock -c 222222 --nofork";
      xautolock.nowlocker = "${pkgs.i3lock}/bin/i3lock -c 222222 --nofork";
    };

    picom = {
      enable = true;
      backend = "glx";
      vSync = true;
      inactiveOpacity = 0.9;
      opacityRules = [
        "100:focused"
        "100:class_g = 'dmenu'"
        "100:class_g = 'Rofi'"
        "100:class_g = 'Chromium-browser'"
        "100:class_g = 'Firefox'"
        "100:class_g = 'Zathura'"
        "100:class_g = 'i3lock'"
        "100:class_g = 'xautolock'"
        "100:class_g = 'mpv'"
        "100:class_g = 'feh'"
      ];
      fade = true;
    };
  };
}
