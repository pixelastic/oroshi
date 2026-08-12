## Migrate audio/ general scripts to autoloaded

### Scripts

| Script | Keybinding update? |
|--------|-------------------|
| `audio-play` | No |
| `audio-play-oroshi` | No |
| `audio-split` | No |
| `sound-mode-is-enabled` | No |
| `sound-mode-toggle` | `$BIN/audio/sound-mode-toggle` → `bin-zsh sound-mode-toggle` |
| `mp32json` | No |
| `mp32vtt` | No |

### Also

- Move `__data/autocorrect.conf` with mic2txt migration
