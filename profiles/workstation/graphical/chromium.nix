{ config, pkgs, inputs, ... }:
let
  dotfiles = inputs.dotfiles;
in
{

  environment.systemPackages = with pkgs; [
    # https://github.com/NixOS/nixpkgs/pull/116218
    (chromium.override { commandLineArgs = "--enable-features=VaapiVideoDecoder"; })
  ];

  programs = {
    chromium.enable = true;
    chromium.extraOpts = {
      BrowserSignIn = 0;
      RestoreOnStartup = 4;
      RestoreOnStartupURLs = [
        "https://kernel.org/"
        "https://hydra.nixos.org/job/nixpkgs/trunk/linux_5_10.x86_64-linux"
        "https://news.ycombinator.com/"
        "https://lobste.rs/"
        "https://apod.nasa.gov/apod/astropix.html"
      ];
    };
    chromium.extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "gcbommkclmclpchllfjekcdonpmejbdp" # HTTPS Everywhere
      "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy Badger
      "eekailopagacbcdloonjhbiecobagjci" # Go Back With Backspace
      "kkhfnlkhiapbiehimabddjbimfaijdhk" # Gopass Bridge (Don't forget to change keyboard shortcut)
      "fhcgjolkccmbidfldomjliifgaodjagh" # Cookie Auto Delete
      "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
      "aleakchihdccplidncghkekgioiakgal" # h264ify
    ];
  };

  home-manager.users.kraem = { ... }: {
    xdg.configFile."chromium/NativeMessagingHosts/com.justwatch.gopass.json".source =
      (dotfiles + "/gopass/com.justwatch.gopass.json");
    xdg.configFile."gopass/gopass_wrapper.sh".source =
      (dotfiles + "/gopass/gopass_wrapper.sh");
  };

}
