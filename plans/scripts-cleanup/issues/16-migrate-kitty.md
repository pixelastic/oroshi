## Migrate kitty/ to autoloaded (32 scripts)

All 32 kitty-* scripts → autoloaded functions.

### Kitty keybindings to update (keybindings.conf)

| Current | New |
|---------|-----|
| `/home/tim/.oroshi/scripts/bin/kitty/kitty-window-toggle-claude` | `bin-zsh kitty-window-toggle-claude` |
| `/home/tim/.oroshi/scripts/bin/kitty/kitty-reload` | `bin-zsh kitty-reload` |
| `/home/tim/.oroshi/scripts/bin/kitty/kitty-tab-create-interactive` | `bin-zsh kitty-tab-create-interactive` |
| `/home/tim/.oroshi/scripts/bin/kitty/kitty-ctrl-p` | `bin-zsh kitty-ctrl-p` |
| `/home/tim/.oroshi/scripts/bin/kitty/kitty-fullscreen-toggle` | `bin-zsh kitty-fullscreen-toggle` |

### Ubuntu keybinding to update

- `$BIN/kitty/kitty-restore` → `bin-zsh kitty-restore`

### Also move

- `__config/session.conf` alongside the autoloaded functions
