{ config, pkgs, stdenv, inputs, ... }:
let

in
{

  environment.systemPackages = with pkgs; [
    isync
  ];

  nixpkgs.overlays = [
    (self: super: {
      isync = super.isync.overrideAttrs (oldAttrs: rec {
          pname = "isync-gsasl";
          buildInputs = [ pkgs.openssl pkgs.db pkgs.gsasl pkgs.zlib ];
        });
      })
  ];

}
