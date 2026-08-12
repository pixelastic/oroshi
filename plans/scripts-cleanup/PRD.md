## Problem Statement

After the first cleanup pass (issues 01-17), `scripts/bin/` still contains ~283 files. Many root-level scripts are unused/dead, and surviving ones need renaming or migration to autoloaded functions. A second interactive audit covered all root-level scripts and all subdirectory domains.

## Solution

Systematic cleanup of all remaining `scripts/bin/` contents:
1. Delete dead/unused scripts
2. Rename inconsistently named scripts
3. Migrate eligible scripts to autoloaded ZSH functions
4. Update all callers (NeoVim, keybindings, aliases, other scripts)
5. Cleanup dead config (xbindkeys, skills npm dep)

## Guiding Principles

- Every ZSH script that can be an autoloaded function should become one
- Scripts called from NeoVim/keybindings/non-ZSH → use `bin-zsh` prefix after migration
- Scripts with `__lib/` or `__rules/` → adapt path resolution after migration
- Scripts in non-ZSH languages (Bash, Node, Rust) → stay as scripts or use wrapper pattern
- Small issues, one domain at a time

## Scripts that remain as scripts after cleanup

| Script | Reason |
|--------|--------|
| `bin-zsh` | Core dispatcher, called from non-ZSH contexts |
| `spotify-dbus` (ex `sp`) | Bash third-party, not convertible |
| `bats-echo` | Deleted (dead code) |
| `bats-fixture-script-*` | Test fixtures, must be on-disk scripts |
| `git/hooks/pre-commit` | Deleted (dead code) |

## Out of Scope

- exa → eza migration (separate task)
- Autoloaded function refactoring (only migration, not code changes)
