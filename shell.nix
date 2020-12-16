let
  pkgs = (import ./nix).pkgs { };
in
pkgs.mkShell {
  name = "nix-config";
  buildInputs = with pkgs; [
    niv
    nixpkgs-fmt
    morph
  ];
}
