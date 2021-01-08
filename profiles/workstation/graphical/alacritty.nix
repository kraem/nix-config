{ config, pkgs, inputs, ... }:
let
  dotfiles = inputs.dotfiles;
  alacrittyConf = builtins.toFile "alacritty.yml" ''
    env:
      TERM: xterm-256color

    colors:
      # Default colors
      primary:
        #background: '0x282a36'
        background: '0x333333'
        foreground: '0xf8f8f2'

      # Normal colors
      normal:
        black:   '0x000000'
        red:     '0xff5555'
        green:   '0x50fa7b'
        yellow:  '0xf1fa8c'
        blue:    '0xcaa9fa'
        magenta: '0xff79c6'
        cyan:    '0x8be9fd'
        white:   '0xbfbfbf'

      # Bright colors
      bright:
        black:   '0x575b70'
        red:     '0xff6e67'
        green:   '0x5af78e'
        yellow:  '0xf4f99d'
        blue:    '0xcaa9fa'
        magenta: '0xff92d0'
        cyan:    '0x9aedfe'
        white:   '0xe6e6e6'

    # Font configuration
    font:
      # Normal (roman) font face
      normal:
        # Font family
        #
        # Default:
        #   - (macOS) Menlo
        #   - (Linux/BSD) monospace
        #   - (Windows) Consolas
        #family: Hack
        #family: Iosevka
        #family: Iosevka Custom
        #family: DejaVu Sans Mono
        family: Menlo

        # The `style` can be specified to pick a specific face.
        #style: Regular

      # Bold font face
      bold:
        # Font family
        #
        # If the bold family is not specified, it will fall back to the
        # value specified for the normal font.
        #family: Hack

        # The `style` can be specified to pick a specific face.
        style: Bold

      # Italic font face
      italic:
        # Font family
        #
        # If the italic family is not specified, it will fall back to the
        # value specified for the normal font.
        #family: monospace

        # The `style` can be specified to pick a specific face.
        style: Italic

      # Bold italic font face
      bold_italic:
        # Font family
        #
        # If the bold italic family is not specified, it will fall back to the
        # value specified for the normal font.
        #family: monospace

        # The `style` can be specified to pick a specific face.
        style: Bold Italic

      # Point size
      size: 12.0

    key_bindings:
      # (Windows, Linux, and BSD only)
      #- { key: V,        mods: Control|Shift, action: Paste            }
      #- { key: C,        mods: Control|Shift, action: Copy             }
      #- { key: Insert,   mods: Shift,         action: PasteSelection   }
      - { key: Key0,     mods: Control|Shift, action: ResetFontSize     }
      #- { key: Equals,   mods: Control,       action: IncreaseFontSize }
      #- { key: Add,      mods: Control,       action: IncreaseFontSize }
      - { key: Minus, mods: Control,       action: DecreaseFontSize }
      #- { key: Minus,    mods: Control,       action: DecreaseFontSize }

      # (Windows only)
      #- { key: Return,   mods: Alt,           action: ToggleFullscreen }

      # (macOS only)
      #- { key: Key0,   mods: Command,         action: ResetFontSize    }
      #- { key: Equals, mods: Command,         action: IncreaseFontSize }
      #- { key: Add,    mods: Command,         action: IncreaseFontSize }
      #- { key: Minus,  mods: Command,         action: DecreaseFontSize }
      #- { key: K,      mods: Command,         action: ClearHistory     }
      #- { key: K,      mods: Command,         chars: "\x0c"            }
      #- { key: V,      mods: Command,         action: Paste            }
      #- { key: C,      mods: Command,         action: Copy             }
      #- { key: H,      mods: Command,         action: Hide             }
      #- { key: M,      mods: Command,         action: Minimize         }
      #- { key: Q,      mods: Command,         action: Quit             }
      #- { key: W,      mods: Command,         action: Quit             }
      #- { key: F,      mods: Command|Control, action: ToggleFullscreen }

      #- { key: Paste,                    action: Paste                            }
      #- { key: Copy,                     action: Copy                             }
      #- { key: L,         mods: Control, action: ClearLogNotice                   }
      #- { key: L,         mods: Control, chars: "\x0c"                            }
      #- { key: PageUp,    mods: Shift,   action: ScrollPageUp,   mode: ~Alt       }
      #- { key: PageDown,  mods: Shift,   action: ScrollPageDown, mode: ~Alt       }
      #- { key: Home,      mods: Shift,   action: ScrollToTop,    mode: ~Alt       }
      #- { key: End,       mods: Shift,   action: ScrollToBottom, mode: ~Alt       }
      - { key: K,          mods: Shift|Control,   action: ScrollLineUp,    mode: ~Alt       }
      - { key: J,          mods: Shift|Control,   action: ScrollLineDown,    mode: ~Alt       }
  '';
in
{
  home-manager.users.kraem = { ... }: {
    xdg.configFile."alacritty/alacritty.yml".source = alacrittyConf;
  };
}
