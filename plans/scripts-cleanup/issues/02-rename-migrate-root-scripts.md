## Rename and migrate surviving root-level scripts

### Renames

| Current | New name | Target |
|---------|----------|--------|
| `scripts/bin/order` | `rename-prefix-number` | autoloaded function in `rename/` |
| `zsh/functions/autoload/rename/rename-sequential` | `rename-number` | rename in place |
| `scripts/bin/swapclean` | `swap-clean` | autoloaded function in `system/` |
| `scripts/bin/hx` | `html-get` | autoloaded function in `html/` |
| `scripts/bin/md2html` | `md2html` | autoloaded function in `markdown/` |
| `scripts/bin/urls` | TBD | TBD domain, name to decide with user |

### Migration checklist per script

1. Rewrite to ZSH if needed (order is Ruby)
2. Remove shebang, move doc comment to line 1
3. Add `setopt local_options err_return`
4. Move to `tools/term/zsh/config/functions/autoload/<domain>/`
5. Update compdef entries
6. Update aliases if any
7. Update tests if any (rename-sequential has tests)
8. Verify with `zsh-lint`

### Notes

- `order` (Ruby) needs full rewrite to ZSH
- `rename-sequential` rename to `rename-number` also requires updating its tests
- `urls` name/domain deferred — to discuss with user
