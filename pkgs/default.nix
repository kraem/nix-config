# https://github.com/Kloenk/nix/blob/15077ec4aa64bfd60c7c32029949b017f04a8b72/pkgs/default.nix
# not needed
{ overlays ? [ ], nixpkgs ? <nixpkgs>, ... }@args:

import nixpkgs (args // { overlays = [ (import ./overlay.nix) ] ++ overlays; })
