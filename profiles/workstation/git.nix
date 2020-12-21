{ config, pkgs, sources, ... }:

# not really needed - just saving as a proof of concept..
let
  gitconfig-orig = ((import ../../nix).dotfiles + "/git/gitconfig");
  gitconfig = pkgs.runCommand "sed" { } ''
    mkdir $out
    sed 's/EMAIL/${email}/g' ${gitconfig-orig} > $out/gitconfig
  '';
  email = (import ../../secrets/secrets.nix).email.gitEmailAddress;
in

{
  home-manager.users.kraem = { ... }: {
    programs.git = {
      enable = true;
    };
    home.file.".gitconfig".source = gitconfig + "/gitconfig";
  };
}
