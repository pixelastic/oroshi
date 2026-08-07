## TLDR

Clean up system/desktop domain scripts: rename to sys- prefix, migrate, document, justify stayers.

## What to build

Scripts in scope (5):
- `better-keepass` — open KeePass with GTK scaling
- `cpu-percent` — CPU usage percentage (rename per map, likely sys- prefix)
- `ram-percent` — RAM usage percentage (rename per map, likely sys- prefix)
- `dconf-watch` — listen to dconf/gsettings changes
- `statusbar-clock` — Kitty statusbar clock (must stay script — called by Python)

Note: `better-keepass` is called by Ubuntu keybindings (Super+K) — call site becomes `bin-zsh better-keepass`. `statusbar-clock` is called by Kitty statusbar Python code — call site becomes `bin-zsh statusbar-clock`.

For each script:
1. Migrate to autoloaded function
2. Apply renames from rename map (issue 02)
3. Update external call sites to `bin-zsh <function>`
4. Update aliases and references

## Acceptance criteria

- [ ] All scripts migrated to autoloaded functions
- [ ] Renames applied per rename map
- [ ] External call sites updated to use `bin-zsh`
- [ ] `zsh-lint` passes on all touched files
