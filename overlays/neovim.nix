{ config, pkgs, stdenv, ... }:
let

in
{

  environment.systemPackages = with pkgs; [
    gopls
    gotools
  ];

  nixpkgs.overlays = [
    (self: super: {

      neovim = (super.pkgs.neovim-unwrapped.override { }).overrideAttrs (
        oldAttrs: rec {
          pname = "neovim-unwrapped";
          version = "master";

          propagatedBuildInputs = [ pkgs.tree-sitter ];

          src = self.fetchFromGitHub {
            owner = "neovim";
            repo = "neovim";
            rev = "${version}";
            sha256 = "sha256-6JwDtYHrC+hU2dfuHYBMHDD2pLbOfTDf5lwBMFFNjOY=";
          };
        }
      );
    })
  ];

}
