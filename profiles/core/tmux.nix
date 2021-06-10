{ config, pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    tmux
  ];
  home-manager.users.kraem = { ... }: {
    programs.tmux = {
      enable = true;
      extraConfig = ''
        set-option -g default-shell $SHELL
        unbind-key C-b
        set-option -g prefix C-a
        bind-key C-a send-prefix

        set -g mouse on

        set -g base-index 1

        set-window-option -g aggressive-resize on

        set-window-option -g mode-keys vi
        bind-key -T copy-mode-vi 'v' send -X begin-selection
        bind-key -T copy-mode-vi 'y' send -X copy-selection-no-clear

        # For ESC delay when using (n)vim in a tmux session
        set -sg escape-time 0

        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        bind C-h resize-pane -L
        bind C-j resize-pane -D
        bind C-k resize-pane -U
        bind C-l resize-pane -R

        bind c new-window -c "#{pane_current_path}"
        bind '"' split-window -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

        #set -g pane-border-style fg=colour245
        #set -g pane-active-border-style "bg=default fg=colour14"

        bind H  previous-window
        bind L next-window

        set -g status-position top
        set -g status-justify left
        set -g status-bg '#f8f9fa'
        #set -g status-fg colour15
        set -g status-interval 2
        setw -g window-status-current-style fg=magenta,bg=brightwhite
        setw -g window-status-style fg=magenta,bg='#E7EAED'
        set -g status-left "#S "
        set -g status-right ""

        set-option -g visual-activity off
        set-option -g visual-bell off
        set-option -g visual-silence off
        set-window-option -g monitor-activity off
        set-option -g bell-action none

        # old..
        #set -g default-terminal "screen-256color"

        # new..
        # https://github.com/alacritty/alacritty/issues/109#issuecomment-507026155
        set  -g default-terminal "tmux-256color"
        set -ag terminal-overrides ",alacritty:RGB"

        # alternatively..
        #set  -g default-terminal "tmux-256color"
        #set -ag terminal-overrides ",alacritty:RGB"
        # in conjunction with (in alacritty.yml):
        # env:
        # TERM: xterm-256color
      '';
    };
  };
}
