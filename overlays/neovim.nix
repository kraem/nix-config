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
          version = "6d67cf8647d251df4b1ded60b4ae3d49a1f73ad3";

          propagatedBuildInputs = [ pkgs.tree-sitter ];

          src = self.fetchFromGitHub {
            owner = "neovim";
            repo = "neovim";
            rev = "${version}";
            sha256 = "sha256-3nX12AG/xc6yoTQtAIcJw6/f/TGyN8mt+/P1WpI8FQY=";
          };
        }
      );
    })
  ];

}
