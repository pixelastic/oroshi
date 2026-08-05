## TLDR

Clean up image domain: rewrite Ruby to ZSH, rename to domain-action pattern, migrate, document.

## What to build

Scripts in scope:
- `image-orientation` (Ruby → ZSH rewrite)
- `gifmin` → `gif-min` (rename)
- `jpgmin` → `jpg-min` (rename)
- `pngalpha` → `png-alpha` (rename)
- `pngblack` → `png-black` (rename)
- `pngmask` → `png-mask` (rename)
- `pngunalpha` → `png-unalpha` (rename)

For each script:
1. Rewrite from Ruby to ZSH if needed
2. Rename per rename map (issue 02)
3. Check if called from non-ZSH context
4. Migrate to autoloaded function or justify as script
5. Ensure doc comment present
6. Update aliases and references

## Acceptance criteria

- [ ] Ruby scripts rewritten to ZSH
- [ ] All renames applied per rename map
- [ ] Each script migrated to autoloaded function or has `# Script because:`
- [ ] All scripts/functions have doc comments
- [ ] `zsh-lint` passes on all touched files
