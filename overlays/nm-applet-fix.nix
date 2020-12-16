{ config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      systemd.user.services.nm-applet.serviceConfig.ExecStart.ExecStart = super.systemd.user.services.nm-applet.serviceConfig.ExecStart.ExecStart.overrideAttrs (oldAttrs: rec {
        ExecStart = [ "" "${pkgs.bash}/bin/bash -c '${pkgs.networkmanagerapplet}/bin/nm-applet' " ];
      });
    })
  ];
}
