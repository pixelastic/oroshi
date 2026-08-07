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
2. Migrate to autoloaded function
3. Apply renames from rename map (issue 02)
4. If called from external context, update call site to `bin-zsh <function>`
5. Update aliases and references

## Acceptance criteria

- [ ] All Ruby/Bash scripts rewritten to ZSH
- [ ] All scripts migrated to autoloaded functions
- [ ] Renames applied per rename map
- [ ] External call sites updated to use `bin-zsh`
- [ ] `zsh-lint` passes on all touched files
