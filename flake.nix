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
      inherit (nixpkgs.lib) foldl' recursiveUpdate nixosSystem mapAttrs;

      # We only evaluate server configs in the context of the system architecture
      # they are deployed to
      system = "x86_64-linux";

      secrets = import ./secrets/secrets.nix;
      sshPort = (builtins.toString secrets.ssh.port);

      mkSystem = module:
        nixosSystem {
          specialArgs = {
            inherit inputs;
          };

          modules = [
            ({ systemd.package = (import staging { inherit system; }).systemd; })
            module
            impermanence.nixosModules.impermanence
            home-manager.nixosModules.home-manager
          ];

          inherit system;
        };
    in
    foldl' recursiveUpdate {} [
       {

        nixosConfigurations.ursa = mkSystem ./hosts/ursa.nix;
        nixosConfigurations.frigate = mkSystem ./hosts/frigate.nix;
        nixosConfigurations.lb1 = mkSystem ./hosts/lb1.nix;
        nixosConfigurations.git = mkSystem ./hosts/git.nix;
        nixosConfigurations.synapse = mkSystem ./hosts/synapse.nix;

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
        checks = mapAttrs (_: lib: lib.deployChecks self.deploy) deploy-rs.lib;
      }

      (flake-utils.lib.eachDefaultSystem (system:
        let
          #overlay = import ./pkgs inputs;
          pkgs = import nixpkgs { inherit system; }; #nixpkgs.legacyPackages.${system};

          inherit (pkgs) mkShell;

          deploy-host = pkgs.writeScriptBin "d" ''
            #!${pkgs.stdenv.shell}
            ${deploy-rs.packages."${system}".deploy-rs}/bin/deploy .#$@
          '';

          build-host = pkgs.writeScriptBin "b" ''
            #!${pkgs.stdenv.shell}
            ${pkgs.nixUnstable}/bin/nix build .#nixosConfigurations.$@.config.system.build.toplevel
          '';

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
              nixUnstable

              deploy-host
              build-host

              deploy-rs.defaultPackage.${system}
            ];
          };
        }))
    ];
}
