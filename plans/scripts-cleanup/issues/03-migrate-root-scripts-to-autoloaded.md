## Migrate root-level scripts to autoloaded functions

### Scripts to migrate (no rename)

| Script | Target domain |
|--------|--------------|
| `apt-packages-cache-generate` | apt-get/ |
| `better-cat` | TBD |
| `better-ls` | TBD |
| `better-ydotool` | TBD |
| `colors` | TBD |
| `colors-reload` | TBD |
| `extract` | TBD |
| `gif2png` | img/ |
| `glob` | TBD |
| `table` | TBD |
| `watch-and-reload` | TBD |

### Scripts to migrate + rename

| Script | New name | Target domain |
|--------|----------|--------------|
| `order` | `rename-prefix-number` | rename/ |
| `rename-sequential` | `rename-number` | rename/ |
| `swapclean` | `swap-clean` | system/ |
| `hx` | `html-get` | html/ |
| `md2html` | `md2html` | markdown/ |
| `urls` | TBD | TBD |

### Migration checklist per script

1. Rewrite to ZSH if needed (`order` is Ruby)
2. Remove shebang, move doc comment to line 1
3. Replace `set -e` with `setopt local_options err_return`
4. Move to `tools/term/zsh/config/functions/autoload/<domain>/`
5. Update compdef entries
6. Update aliases if any
7. Update tests if any (`rename-sequential` has tests)
8. Verify with `zsh-lint`

### Notes

- `order` (Ruby) needs full rewrite to ZSH
- `rename-sequential` → `rename-number` requires updating its tests
- `urls` name/domain deferred
- Domains for `better-*`, `colors*`, `extract`, `glob`, `table`, `watch-and-reload` to decide during implementation
