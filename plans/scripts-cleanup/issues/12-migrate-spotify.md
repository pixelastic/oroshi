## Migrate spotify/ to autoloaded + rename sp

### Rename

- `scripts/bin/sp` → `spotify/spotify-dbus` (stays as bash script)

### Migrate to autoloaded functions

| Script | Rewrite? | Keybinding update? |
|--------|----------|-------------------|
| `spotify` | No (ZSH) | Ubuntu custom + (xbindkeys deleted) → `bin-zsh spotify` |
| `spotify-is-running` | No (ZSH) | No (internal dep) |
| `spotify-next` | Yes (Bash→ZSH) | Ubuntu custom → `bin-zsh spotify-next` |
| `spotify-previous` | Yes (Bash→ZSH) | Ubuntu custom → `bin-zsh spotify-previous` |
| `spotify-toggle-pause` | Yes (Bash→ZSH) | No (internal dep) |
| `spotify-playlist-play` | Yes (Bash→ZSH) | Ubuntu custom → `bin-zsh spotify-playlist-play` |

### Update all `sp` calls to `spotify-dbus`

All spotify/* scripts call `sp` — update to `spotify-dbus`.
