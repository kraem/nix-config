{ config, pkgs, ... }:

{
  #services.emacs.enable = true;

  environment.systemPackages = with pkgs; [
    emacs
    emacs-all-the-icons-fonts
  ];

}
