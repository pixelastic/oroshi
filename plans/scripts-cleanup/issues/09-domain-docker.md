## TLDR

Clean up docker domain scripts: migrate to autoloaded functions where possible, document, justify stayers.

## What to build

Scripts in scope (9):
- `docker-container-list`
- `docker-image-build`
- `docker-image-push`
- `docker-images-remote-refresh`
- `docker-oroshi-commit`
- `docker-oroshi-list`
- `docker-oroshi-run`
- `docker-run-interactive`
- `docker-run`

For each script:
1. Check if called from non-ZSH context
2. Migrate to autoloaded function or justify as script
3. Ensure doc comment present
4. Update aliases and references

## Acceptance criteria

- [ ] Each script migrated to autoloaded function or has `# Script because:`
- [ ] All scripts/functions have doc comments
- [ ] `zsh-lint` passes on all touched files
