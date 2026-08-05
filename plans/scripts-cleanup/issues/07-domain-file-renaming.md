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
2. Apply domain naming from rename map
3. Check if called from non-ZSH context
4. Migrate to autoloaded function or justify as script
5. Ensure doc comment present
6. Update aliases and references

## Acceptance criteria

- [ ] All Ruby scripts rewritten to ZSH
- [ ] Domain naming applied per rename map
- [ ] Each script migrated to autoloaded function or has `# Script because:`
- [ ] All scripts/functions have doc comments
- [ ] `zsh-lint` passes on all touched files
