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
2. Migrate to autoloaded function
3. Rename per rename map (issue 02)
4. If called from external context, update call site to `bin-zsh <function>`
5. Update aliases and references

## Acceptance criteria

- [ ] Ruby scripts rewritten to ZSH
- [ ] All scripts migrated to autoloaded functions
- [ ] All renames applied per rename map
- [ ] External call sites updated to use `bin-zsh`
- [ ] `zsh-lint` passes on all touched files
