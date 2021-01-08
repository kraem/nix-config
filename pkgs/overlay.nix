# https://github.com/Kloenk/nix/blob/15077ec4aa64bfd60c7c32029949b017f04a8b72/pkgs/overlay.nix
inputs: final: prev:
let inherit (final) callPackage;
in {
  menlo-font = callPackage ./menlo-font { };
}
