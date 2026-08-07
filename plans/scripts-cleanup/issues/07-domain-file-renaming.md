## TLDR

Clean up file-renaming domain: rewrite Ruby to ZSH, establish domain naming, migrate, document.

## What to build

Scripts in scope:
- `file2dir` (Ruby → ZSH rewrite, rename TBD)
- `prefix-date` (Ruby → ZSH rewrite, rename TBD)
- `rename-fat32` (Ruby → ZSH rewrite, rename TBD)
- `capitalize-title` (Ruby → ZSH rewrite, rename TBD)
- `sequential-rename` (rename TBD)
- `filename-valid` (rename TBD)

These scripts all modify filenames. The rename map (issue 02) will determine the domain name and naming convention.

For each script:
1. Rewrite from Ruby to ZSH if needed
2. Migrate to autoloaded function
3. Apply domain naming from rename map
4. If called from external context, update call site to `bin-zsh <function>`
5. Update aliases and references

## Acceptance criteria

- [ ] All Ruby scripts rewritten to ZSH
- [ ] All scripts migrated to autoloaded functions
- [ ] Domain naming applied per rename map
- [ ] External call sites updated to use `bin-zsh`
- [ ] `zsh-lint` passes on all touched files
