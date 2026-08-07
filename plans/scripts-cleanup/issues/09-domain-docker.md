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
1. Migrate to autoloaded function
2. If called from external context, update call site to `bin-zsh <function>`
3. Update aliases and references

## Acceptance criteria

- [ ] All scripts migrated to autoloaded functions
- [ ] External call sites updated to use `bin-zsh`
- [ ] `zsh-lint` passes on all touched files
