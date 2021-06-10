{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    alacritty
    arandr
    arc-icon-theme
    deluge
    discord
    element-desktop
    feh
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
    pscircle
    (rofi.override { plugins = [ pkgs.rofi-emoji ]; })
    rxvt_unicode
    scrot
    slack
    spotify
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

  # TODO export out of xorg
  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      menlo-font
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
    gnome.gnome-keyring.enable = true;
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

      libinput = {
        enable = true;
        touchpad = {
          naturalScrolling = true;
          disableWhileTyping = true;
        };
      };

      xautolock.enable = true;
      xautolock.extraOptions = [
        "-corners 0-0-"
      ];
      xautolock.locker = "${pkgs.i3lock}/bin/i3lock -c DEF3FD --nofork";
      xautolock.nowlocker = "${pkgs.i3lock}/bin/i3lock -c DEF3FD --nofork";
    };

    picom = {
      enable = true;
      backend = "glx";
      vSync = true;
      inactiveOpacity = 0.95;
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
