{
  description = "kraem infra";

  inputs = {
    nix = { url = "github:NixOS/nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    staging.url = "github:NixOS/nixpkgs/staging";
    flake-utils = { url = "github:numtide/flake-utils"; inputs.nixpkgs.follows = "nixpkgs"; };
    impermanence = { url = "github:nix-community/impermanence"; inputs.nixpkgs.follows = "nixpkgs"; };
    home-manager = { url = "github:rycee/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    deploy-rs = { url = "git+https://github.com/kraem/deploy-rs?ref=fix/magic-rollback-pseudo-terminal"; inputs.nixpkgs.follows = "nixpkgs"; };
    dotfiles = { url = "github:kraem/dotfiles"; flake = false; };
  };

  outputs = { self,
    nixpkgs,
    staging,
    flake-utils,
    impermanence,
    deploy-rs,
    home-manager,
    dotfiles,
    ... }@inputs:
    let
      inherit (nixpkgs.lib) nixosSystem mapAttrs;
      mkShell = nixpkgs.legacyPackages.x86_64-linux.mkShell;

      secrets = import ./secrets/secrets.nix;
      sshPort = (builtins.toString secrets.ssh.port);

      # TODO figure out how to not have ${system} below depend on this scope
      system = "x86_64-linux";

      mkSystem = system: module:
        nixosSystem {
          specialArgs = {
            inherit inputs;
          };

          inherit system;

          modules = [
            module
            impermanence.nixosModules.impermanence
            home-manager.nixosModules.home-manager
          ];
        };
    in
      (flake-utils.lib.eachDefaultSystem (system: {

        defaultApp = self.apps.${system}.deploy;

        apps = {
          deploy = {
            type = "app";
            program = "${deploy-rs.packages."${system}".deploy-rs}/bin/deploy";
          };
        };

        devShell = mkShell {
          buildInputs = with nixpkgs.legacyPackages.${system}; [
            nixUnstable
            deploy-rs.defaultPackage.${system}
          ];
        };
      })) //
      {
        nixosConfigurations.ursa = mkSystem "x86_64-linux" ./hosts/ursa.nix;
        nixosConfigurations.frigate = mkSystem "x86_64-linux" ./hosts/frigate.nix;
        nixosConfigurations.lb1 = mkSystem "x86_64-linux" ./hosts/lb1.nix;
        nixosConfigurations.git = mkSystem "x86_64-linux" ./hosts/git.nix;
        nixosConfigurations.synapse = mkSystem "x86_64-linux" ./hosts/synapse.nix;

        # Deployment expressions
        deploy.nodes.ursa = {
          hostname = "${secrets.hosts.ursa.domain}";
          profiles = {
            system = rec {
              sshUser = "morph";
              user = "root";
              sshOpts = [ "-p" "${sshPort}" ];
              path = deploy-rs.lib.${system}.activate.nixos
                self.nixosConfigurations.ursa;
            };
          };
        };

        deploy.nodes.frigate = {
          hostname = "${secrets.hosts.frigate.domain}";
          profiles = {
            system = rec {
              sshUser = "morph";
              user = "root";
              sshOpts = [ "-p" "${sshPort}" ];
              path = deploy-rs.lib.${system}.activate.nixos
                self.nixosConfigurations.frigate;
            };
          };
        };

        deploy.nodes.lb1 = {
          hostname = "${secrets.hosts.lb1.domain}";
          profiles = {
            system = rec {
              sshUser = "morph";
              user = "root";
              sshOpts = [ "-p" "${sshPort}" ];
              path = deploy-rs.lib.${system}.activate.nixos
                self.nixosConfigurations.lb1;
            };
          };
        };

        deploy.nodes.git = {
          hostname = "${secrets.hosts.git.domain}";
          profiles = {
            system = rec {
              sshUser = "morph";
              user = "root";
              sshOpts = [ "-p" "${sshPort}" ];
              path = deploy-rs.lib.${system}.activate.nixos
                self.nixosConfigurations.git;
            };
          };
        };

        deploy.nodes.synapse = {
          hostname = "${secrets.hosts.synapse.domain}";
          profiles = {
            system = rec {
              sshUser = "morph";
              user = "root";
              sshOpts = [ "-p" "${sshPort}" ];
              path = deploy-rs.lib.${system}.activate.nixos
                self.nixosConfigurations.synapse;
            };
          };
        };

        # Verify schema of .#deploy
        #checks = mapAttrs (_: lib: lib.deployChecks self.deploy) deploy-rs.lib;
        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
      };
}
