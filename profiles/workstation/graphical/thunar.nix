{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    xfce.thunar
  ];

  # tumbler is needed for picture thumbnails
  services.tumbler.enable = true;

  # For browsing iOS devices with afc://<serial_number>
  # afc://<serial_number> addresses are already activated in thunar with gvfs:
  # https://github.com/NixOS/nixpkgs/blob/29062cec8d214013a8e1f944d16e32c36294e0d0/pkgs/desktops/xfce/core/thunar/default.nix#L38
  services.gvfs.enable = true;

  # usbmuxd
  # manually: sudo usbmuxd -u -v -f -U kraem
  services.usbmuxd.enable = true;

  # TODO
  # dconf is needed to save thunar settings between restarts
  # haven't got it working yet
  programs.dconf.enable = true;

}
