{
  description = "kraem infra";

  inputs = {
    nix.url = "github:NixOS/nix";
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:rycee/home-manager";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    deploy-rs = {
      type = "github";
      owner = "kraem";
      repo = "deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles = {
      url = "github:kraem/dotfiles";
      flake = false;
    };
  };

  outputs = { self,
    nixpkgs,
    flake-utils,
    deploy-rs,
    home-manager,
    dotfiles,
    ... }@inputs:
  let
    inherit (nixpkgs.lib) foldl' recursiveUpdate nixosSystem mapAttrs;

    # We only evaluate server configs in the context of the system architecture
    # they are deployed to
    system = "x86_64-linux";
    mkSystem = module: nixosSystem {
      specialArgs = {
        inherit inputs;
      };

      modules = [
        module
        home-manager.nixosModules.home-manager
      ];

      inherit system;
    };
  in
    foldl' recursiveUpdate {} [
       {

        nixosConfigurations.ursa = mkSystem ./hosts/ursa.nix;
        nixosConfigurations.lb1 = mkSystem ./hosts/lb1.nix;

        # Deployment expressions
        deploy.nodes.ursa = {
          hostname = "localhost";
          profiles = {
            system = rec {
              sshUser = "morph";
              user = "root";
              sshOpts = [ "-p" "25001" ];
              #magicRollback = false;
              path = deploy-rs.lib.${system}.activate.nixos
                self.nixosConfigurations.ursa;
            };
          };
        };

        deploy.nodes.lb1 = {
          hostname = "192.168.1.20";
          profiles = {
            system = rec {
              sshUser = "morph";
              user = "root";
              sshOpts = [ "-p" "25001" ];
              #magicRollback = false;
              path = deploy-rs.lib.${system}.activate.nixos
                self.nixosConfigurations.lb1;
            };
          };
        };

        # Verify schema of .#deploy
        checks = mapAttrs (_: lib: lib.deployChecks self.deploy) deploy-rs.lib;
      }

      (flake-utils.lib.eachDefaultSystem (system:
        let
          #overlay = import ./pkgs inputs;
          pkgs = nixpkgs.legacyPackages.${system};

          inherit (pkgs) mkShell;
        in {
          defaultApp = self.apps.${system}.deploy;
          #defaultPackage = builtins.trace (self.packages.${system}.hosts) self.packages.${system}.hosts;

          apps = {
            deploy = {
              type = "app";
              program = "${deploy-rs.packages."${system}".deploy-rs}/bin/deploy";
            };
          };

          devShell = mkShell {
            buildInputs = with pkgs; [
              # Make sure we have a fresh nix
              nixUnstable

              # deploy tool
              deploy-rs.defaultPackage.${system}
            ];
          };
        }))
    ];
}
