## TLDR

Clean up JSON domain scripts: migrate to autoloaded functions where possible, document, justify stayers.

## What to build

Scripts in scope (3):
- `json-count` — count elements in JSON array
- `json-filter` — filter JSON array by key/value
- `jsonl2json` — convert JSONL to JSON array

For each script:
1. Check if called from non-ZSH context
2. Migrate to autoloaded function or justify as script
3. Ensure doc comment present
4. Update aliases and references

## Acceptance criteria

- [ ] Each script migrated to autoloaded function or has `# Script because:`
- [ ] All scripts/functions have doc comments
- [ ] `zsh-lint` passes on all touched files
