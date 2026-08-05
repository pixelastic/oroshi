## TLDR

Clean up text/encoding domain: rewrite Ruby to ZSH, rename, migrate, document.

## What to build

Scripts in scope (6):
- `url2host` (Ruby → ZSH rewrite)
- `sort-by-length` (Bash → ZSH rewrite)
- `base64decode` — decode base64 (potential rename per map)
- `base64encode` — encode base64 (potential rename per map)
- `xml2json` — convert XML to JSON
- `zsh2json` — transform ZSH env files to JSON (rename per map)

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
