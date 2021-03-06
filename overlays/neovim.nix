{ config, pkgs, stdenv, ... }:
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
          pname = "neovim-unwrapped";
          version = "8f4b9b8b7de3a24279fad914e9d7ad5ac1213034";

          propagatedBuildInputs = [ pkgs.tree-sitter ];

          src = self.fetchFromGitHub {
            owner = "neovim";
            repo = "neovim";
            rev = "${version}";
            sha256 = "sha256-m+1BPfIonmqlZGjCB910kXnc4o0XuyESNM3vyIv94lA=";
          };
        }
      );
    })
  ];

}
