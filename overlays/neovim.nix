{ config, pkgs, stdenv, inputs, ... }:
let

in
{

  environment.systemPackages = with pkgs; [
    gopls
    gotools
    rnix-lsp
  ];

  nixpkgs.overlays = [
    (self: super: {

      neovim = (super.pkgs.neovim-unwrapped.override { }).overrideAttrs (
        oldAttrs: rec {
          pname = "neovim-nightly";
          version = "master";
          src = inputs.neovim-nightly;

          buildInputs = oldAttrs.buildInputs ++ [ pkgs.tree-sitter ];
        });
      })
  ];

}
