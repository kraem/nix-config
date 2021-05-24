{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    (weechat.override {
        configure = { availablePlugins, ... }: {
          plugins = with availablePlugins; [
            (python.withPackages (_: [ weechatScripts.weechat-matrix ]))
          ];
          scripts = with weechatScripts; [
            weechat-autosort
            weechat-matrix
          ];
        };
      })
    weechatScripts.weechat-matrix
  ];

  # TODO define port in weechat module once we add as system service..
  networking.firewall.allowedTCPPorts = [ 26001 ];

}
