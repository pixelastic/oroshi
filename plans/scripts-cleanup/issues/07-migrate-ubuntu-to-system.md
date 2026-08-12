## Migrate ubuntu/ scripts to system/ subdomains

| Script | Destination |
|--------|------------|
| `clipboard-read` | `system/clipboard/` |
| `clipboard-write` | `system/clipboard/` |
| `focus-insert` | `system/` (root) |
| `workspace-current` | `system/workspace/` |
| `workspace-switch` | `system/workspace/` |

### Callers to update

- `clipboard-read`: focus-insert, zsh keybindings (ctrl-y, ctrl-shift-y, ctrl-shift-e)
- `clipboard-write`: many scripts, CLAUDE.md
- `focus-insert`: insert-current-date, insert-uuid
- `workspace-current/switch`: spotify, spotify-playlist-play
