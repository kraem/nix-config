{ config, pkgs, lib, ... }:
let
  secrets = import ../secrets/secrets.nix;
in
{

  services.openssh = {
    enable = true;

    passwordAuthentication = false;
    challengeResponseAuthentication = false;
    # as iso.nix imports graphical image and sets to "yes"..
    permitRootLogin = lib.mkDefault "no";
    ports = [ secrets.ssh.port ];
    openFirewall = true;
    # sshd is now only working over protocol 2 so the config line below is not needed
    #extraConfig = ''Protocol 2'';
  };

  services.fail2ban.enable = true;

}
