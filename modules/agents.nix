{ config, pkgs, ... }:

{
  programs = {

    gnupg.agent = { enable = true; enableSSHSupport = true; };

    # Old hack which isn't needed anymore
    # Saving for reference

    #bash.loginShellInit = ''

    #    # Ugly hack to restart gnome-keyring-daemon on login and exporting the SSH_AUTH_SOCK
    #    # SSH logins are opened by gnome-keyring and GPG logins are done by gpg-agent (pinentry) - why?

    #    # Maybe this hack isn't that ugly after all
    #    # Login shells are shells started when the user first logs in. Not for each shell that is started after login.
    #    # https://unix.stackexchange.com/questions/38175/difference-between-login-shell-and-non-login-shell

    #    ${pkgs.gnome3.gnome-keyring}/bin/gnome-keyring-daemon -r -d
    #    export SSH_AUTH_SOCK=/run/user/1000/keyring/ssh

    #    # This solution is only feasible for single user systems obviously. Not sure how this would be done otherwise.

    #    PATH=~/bin/monitor/:$PATH
    #'';
  };
}
