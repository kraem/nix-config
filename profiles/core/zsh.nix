{ config, pkgs, inputs, ... }:
let
  powerlevel-init = ''
    source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

    # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
    # Initialization code that may require console input (password prompts, [y/n]
    # confirmations, etc.) must go above this block, everything else may go below.
    if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-\$\{(%):-%n}.zsh" ]]; then
      source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-\$\{(%):-%n\}.zsh"
    fi

    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
    ##[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    ${powerlevel-conf}
  '';

  dotfiles = inputs.dotfiles;

  powerlevel-conf =
    builtins.readFile (dotfiles + "/zsh/p10k.zsh");

  zsh-path =
    builtins.readFile (dotfiles + "/zsh/path.zsh");
  zsh-history =
    builtins.readFile (dotfiles + "/zsh/history.zsh");
  zsh-vi-bindings =
    builtins.readFile (dotfiles + "/zsh/vi-bindings.zsh");
  zsh-aliases =
    builtins.readFile (dotfiles + "/zsh/alias.zsh");
  zsh-fzf =
    builtins.readFile (dotfiles + "/zsh/fzf.zsh");
  zsh-direnv =
    builtins.readFile (dotfiles + "/zsh/direnv.zsh");
  # not setting these as nix variables as we want to import them
  # on other systems?
  zsh-env =
    builtins.readFile (dotfiles + "/zsh/env.zsh");
  zsh-gopass =
    builtins.readFile (dotfiles + "/zsh/gopass.zsh");
  zsh-nix =
    builtins.readFile (dotfiles + "/zsh/nix.zsh");
  zsh-zfs =
    builtins.readFile (dotfiles + "/zsh/zfs.zsh");
  # including a mutable file to hack on
  zsh-mutable = ''
    if [[ -r ''${HOME}/.mutable.zsh ]]; then
      source ''${XDG_CACHE_HOME:-$HOME/.mutable.zsh
    fi
  '';

in
{
  environment.pathsToLink = [ "/share/zsh" ];
  home-manager.users.kraem = { ... }: {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      sessionVariables = {
        BAT_THEME = "GitHub";
      };
      initExtraFirst = powerlevel-init;
      initExtra =
        (
          zsh-path +
          zsh-history +
          zsh-vi-bindings +
          zsh-aliases +
          zsh-fzf +
          zsh-direnv +
          zsh-env +
          zsh-gopass +
          zsh-nix +
          zsh-zfs
          #zsh-mutable
        );
    };
  };
  home-manager.users.root = { ... }: {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      initExtraFirst = powerlevel-init;
      initExtra =
        (
          zsh-history +
          zsh-vi-bindings +
          zsh-aliases +
          zsh-fzf +
          zsh-direnv +
          zsh-env +
          zsh-gopass +
          zsh-nix +
          zsh-zfs
          #zsh-mutable
        );
    };
  };
}
