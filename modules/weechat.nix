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

}
