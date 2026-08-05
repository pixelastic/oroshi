## TLDR

Clean up misc personal/file tools: rewrite, migrate, document. Covers small domains and standalone personal scripts.

## What to build

Scripts in scope (~16):
- `rcp` — rsync copy
- `rmv` — rsync move
- `better-rmdir` (Ruby → ZSH rewrite, aliased as `rmdir`)
- `my-ip` (Bash → ZSH rewrite, rename per map)
- `ping-average` (Bash → ZSH rewrite, rename per map)
- `file-count` (Bash → ZSH rewrite, rename per map)
- `unmark` (Bash → ZSH rewrite, rename per map)
- `website-download` — download full website with wget
- `rar-repair` — repair corrupted RAR files
- `kindle-screensaver` — convert image to Kindle format (rename per map)
- `switch-extract` — copy Switch screenshots/videos from SD
- `cesoir` (Ruby → ZSH rewrite) — movie night picker
- `font-exists` (Ruby → ZSH rewrite) — check if font installed
- `html2pdf` (Ruby → ZSH rewrite) — convert HTML to PDF (evaluate feasibility, delete if too complex)
- `isomount` — mount ISO file
- `kitty-tab-window-count` — get window count in Kitty tab

For each script:
1. Rewrite from Ruby/Bash to ZSH if needed
2. Apply renames from rename map (issue 02)
3. Check if called from non-ZSH context
4. Migrate to autoloaded function or justify as script
5. Ensure doc comment present
6. Update aliases and references

## Acceptance criteria

- [ ] All Ruby/Bash scripts rewritten to ZSH
- [ ] Renames applied per rename map
- [ ] Each script migrated to autoloaded function or has `# Script because:`
- [ ] All scripts/functions have doc comments
- [ ] `zsh-lint` passes on all touched files
