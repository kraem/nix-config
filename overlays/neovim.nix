{ config, pkgs, stdenv, ... }:
let

in
{

  environment.systemPackages = with pkgs; [
    gopls
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
            sha256 = "013cibnl0myid8jrihpn4dd21sf8pcynnyhfg1xjaq3rmpjdii7p";
          };
        }
      );
    })
  ];

}
