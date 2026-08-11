## Rename root-level scripts

### Renames

| Current | New name | Notes |
|---------|----------|-------|
| `scripts/bin/f` | `better-find` | Add alias `f` → `better-find` |
| `scripts/bin/g` | `better-grep` | Add alias `g` → `better-grep` |
| `scripts/bin/header` | `http-header` | Move to http/ domain |
| `scripts/bin/http/post` | `http-post` | Rename within http/ domain |
| `scripts/bin/sp` | `spotify/spotify-dbus` | Move into spotify/, stays as bash script |
| `scripts/bin/chmod-default` | `chmod-default` | Rewrite Ruby → ZSH, keep name, find domain |

### Checklist per rename

1. Rename file
2. Update all references in the repo (grep for old name)
3. Update compdef entries if any
4. Update aliases if any
5. For `f`/`g`: create aliases in zsh config
6. For `chmod-default`: rewrite from Ruby to ZSH
7. For `sp` → `spotify-dbus`: update all `spotify/*` wrappers that call `sp`
8. Verify with `zsh-lint`
