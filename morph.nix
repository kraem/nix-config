let

  pkgs = (import ./nix).pkgs { };

in
{
  network = {
    inherit pkgs;
    description = "simple hosts";
  };

  "deploy-frigate" = {
    imports = [
      ./hosts/frigate.nix
    ];
  };

  "deploy-lb1" = {
    imports = [
      ./hosts/lb1.nix
    ];
  };

  "deploy-synapse" = {
    imports = [
      ./hosts/synapse.nix
    ];
  };

  "deploy-git" = {
    imports = [
      ./hosts/git.nix
    ];
  };
}
