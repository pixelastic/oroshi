## Problem Statement

After issues 01-26 migrated most scripts, `scripts/bin/` still has leftover subdirectories, orphaned tests, dead symlinks, and 6 unmigrated scripts. The directory structure uses nested domains that are no longer justified given only ~4 scripts must remain.

## Solution

Final cleanup pass:
1. Flatten `scripts/bin/` — remove all subdirectories except `term/bats/` fixtures
2. Migrate remaining 6 scripts to autoloaded functions
3. Create `misc/better/`, `misc/http/`, `misc/file/` subdomains in autoload
4. Consolidate all `better-*` functions from various domains into `misc/better/`
5. Move orphaned tests to their correct autoload locations
6. Delete dead artifacts (orphan tests, dead symlinks, redundant docs)

## Guiding Principles

- Every ZSH script that can be an autoloaded function should become one
- Scripts called from NeoVim/keybindings/non-ZSH → use `bin-zsh` prefix after migration
- Scripts with `__lib/` or `__rules/` → adapt path resolution after migration
- Scripts in non-ZSH languages (Bash, Node, Rust) → stay as scripts or use wrapper pattern
- Small issues, one domain at a time
- `scripts/bin/` is flat — no domain subdirectories, scripts live at root

## Scripts that remain as scripts after cleanup

| Script | Reason |
|--------|--------|
| `bin-zsh` | Core dispatcher, called from non-ZSH contexts |
| `spotify-dbus` | Bash third-party, not convertible |
| `solkan` (symlink) | External package, used by Claude hooks and prompt |
| `bats-fixture-script-*` | Test fixtures for worktree-aware resolution, must be on-disk scripts in `term/bats/` |

## Target `scripts/bin/` structure

```
scripts/bin/
├── bin-zsh
├── solkan → ../node_modules/.bin/solkan
├── spotify-dbus
├── __tests__/bin-zsh.bats
└── term/bats/
    ├── bats-fixture-script-foo
    ├── bats-fixture-script-bar
    └── bats-fixture-script-baz
```

## Implementation Decisions

- `better-find`, `better-grep` → `misc/better/` (new subdomain)
- `http-header`, `http-post` → `misc/http/` (new subdomain, rewrite to zsh)
- `chmod-default` → `misc/` (root of misc, no subdomain)
- `urls` → `misc/file/file-url-list` (new subdomain, rename)
- All existing `better-*` across all domains → consolidated into `misc/better/`
- `file-count`, `file-hash` → moved from `misc/` to `misc/file/`

## Out of Scope

- exa → eza migration (separate task)
- Autoloaded function refactoring (only migration, not code changes)
