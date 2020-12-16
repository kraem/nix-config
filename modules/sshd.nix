{ config, pkgs, ... }:

{

  services.openssh = {
    enable = true;

    passwordAuthentication = false;
    challengeResponseAuthentication = false;
    permitRootLogin = "no";
    ports = [ 25001 ];
    openFirewall = true;
    # sshd is now only working over protocol 2 so the config line below is not needed
    #extraConfig = ''Protocol 2'';
  };

  services.fail2ban.enable = true;

}
