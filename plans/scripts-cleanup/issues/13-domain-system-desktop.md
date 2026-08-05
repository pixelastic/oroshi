## TLDR

Clean up system/desktop domain scripts: rename to sys- prefix, migrate, document, justify stayers.

## What to build

Scripts in scope (5):
- `better-keepass` — open KeePass with GTK scaling
- `cpu-percent` — CPU usage percentage (rename per map, likely sys- prefix)
- `ram-percent` — RAM usage percentage (rename per map, likely sys- prefix)
- `dconf-watch` — listen to dconf/gsettings changes
- `statusbar-clock` — Kitty statusbar clock (must stay script — called by Python)

Note: `better-keepass` is called by Ubuntu keybindings (Super+K) — must stay as script. `statusbar-clock` is called by Kitty statusbar Python code — must stay as script.

For each script:
1. Apply renames from rename map (issue 02)
2. Check if called from non-ZSH context
3. Migrate to autoloaded function or justify as script
4. Ensure doc comment present
5. Update aliases and references

## Acceptance criteria

- [ ] Renames applied per rename map
- [ ] Each script migrated to autoloaded function or has `# Script because:`
- [ ] All scripts/functions have doc comments
- [ ] `zsh-lint` passes on all touched files
