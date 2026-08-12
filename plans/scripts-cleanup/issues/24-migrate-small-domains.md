## Migrate small domains to autoloaded

### prose/

| Script | NeoVim ? |
|--------|----------|
| `prose-build` | Yes (onWrite trigger in colors.lua) → bin-zsh |
| `prose-lint` | No |

### ebook/

| Script |
|--------|
| `kindle-sync` |

### worktools/

| Script |
|--------|
| `lunii` |

### video/

| Script |
|--------|
| `video-info` |
| `video-stream-list` |

### keybindings/

| Script | Keybinding update? |
|--------|-------------------|
| `insert-current-date` | `$BIN/keybindings/insert-current-date` → `bin-zsh insert-current-date` |
| `insert-uuid` | `$BIN/keybindings/insert-uuid` → `bin-zsh insert-uuid` |

### pdf/

| Script | Notes |
|--------|-------|
| `pdf-extract-images` | Node.js — migrate to ZSH wrapper + `__lib/*.js` pattern |
