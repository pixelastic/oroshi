## TLDR

Clean up JSON domain scripts: migrate to autoloaded functions where possible, document, justify stayers.

## What to build

Scripts in scope (3):
- `json-count` — count elements in JSON array
- `json-filter` — filter JSON array by key/value
- `jsonl2json` — convert JSONL to JSON array

For each script:
1. Migrate to autoloaded function
2. If called from external context, update call site to `bin-zsh <function>`
3. Update aliases and references

## Acceptance criteria

- [ ] All scripts migrated to autoloaded functions
- [ ] External call sites updated to use `bin-zsh`
- [ ] `zsh-lint` passes on all touched files
