{
  description = "kraem infra";

  inputs = {
    nix = { url = "github:NixOS/nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    #nixpkgs.url = "git+https://github.com/kraem/nixpkgs?ref=kraem/zfs/revert-201";
    staging.url = "github:NixOS/nixpkgs/staging";
    flake-utils = { url = "github:numtide/flake-utils"; inputs.nixpkgs.follows = "nixpkgs"; };
    impermanence = { url = "github:nix-community/impermanence"; inputs.nixpkgs.follows = "nixpkgs"; };
    home-manager = { url = "github:rycee/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    deploy-rs = { url = "github:serokell/deploy-rs"; inputs.nixpkgs.follows = "nixpkgs"; };
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
            # https://matrix.to/#/!XXmPwxJAJXDQzaElMj:matrix.org/$1609953554124iSliP:matrix.uni-hannover.de?via=matrix.org&via=tchncs.de&via=privacytools.io
            { nixpkgs.overlays = [ self.overlay ];}
            impermanence.nixosModules.impermanence
            home-manager.nixosModules.home-manager
          ];
        };

      pkgs = import nixpkgs { inherit system; }; #nixpkgs.legacyPackages.${system};

      mkIso = pkgs.writeScriptBin "mkiso" ''
          #!${pkgs.stdenv.shell}
          ${pkgs.nixUnstable}/bin/nix build .#nixosConfigurations.iso.config.system.build.isoImage
        '';
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
            mkIso
          ];
        };
      })) //
      {
        nixosConfigurations.ursa = mkSystem "x86_64-linux" ./hosts/ursa.nix;
        nixosConfigurations.frigate = mkSystem "x86_64-linux" ./hosts/frigate.nix;
        nixosConfigurations.lb1 = mkSystem "x86_64-linux" ./hosts/lb1.nix;
        nixosConfigurations.git = mkSystem "x86_64-linux" ./hosts/git.nix;
        nixosConfigurations.synapse = mkSystem "x86_64-linux" ./hosts/synapse.nix;

        nixosConfigurations.iso = mkSystem "x86_64-linux" ./iso.nix;

        # https://github.com/Kloenk/nix/blob/15077ec4aa64bfd60c7c32029949b017f04a8b72/flake.nix#L164
        overlay = final: prev:
          (import ./pkgs/overlay.nix inputs final prev);

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
