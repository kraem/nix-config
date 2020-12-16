{ sources ? import ./nix, lib ? sources.lib, pkgs ? sources.pkgs { }, home-manager ? sources.home-manager { } }:

with builtins; with lib;
let
  mkNixOS = name: arch:
    let
      configuration = ./hosts + "/${name}.nix";
      system = arch;
      nixos = import (pkgs.path + "/nixos") { inherit configuration system; };
    in
    nixos.config.system.build;

  mkSystem = name: arch: (mkNixOS name arch).toplevel;

in
mapAttrs mkSystem (import ./hosts.nix)
