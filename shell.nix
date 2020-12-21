let
  pkgs = (import ./nix).pkgs { };
in
pkgs.mkShell {
  name = "nix-config";
  buildInputs = with pkgs; [
    git-crypt
    niv
    nixpkgs-fmt
    morph
  ];
}
