{ config, pkgs, ... }:

{
  services = {
    xserver = {
      # Needed by displayManager.lightdm.greeters.mini
      displayManager.defaultSession = "none+i3";
      windowManager.i3.enable = false;
      windowManager.i3.package = pkgs.i3-gaps;
    };
  };
}
