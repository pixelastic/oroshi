## TLDR

Clean up FZF domain scripts: migrate to autoloaded functions where possible, document, justify stayers.

## What to build

Scripts in scope (5):
- `ctrl-shift-o` — fuzzy search directories
- `fzf-apt-packages` — fuzzy search apt packages
- `fzf-git-files-dirty-stageable`
- `fzf-git-files-dirty`
- `fzf-js-test` — fuzzy pick JS test file

Note: FZF scripts in the "alive" list (ctrl-p, ctrl-shift-p, ctrl-g, ctrl-shift-g) are called by NeoVim — call sites become `bin-zsh <function>`.

For each script:
1. Migrate to autoloaded function
2. If called from external context, update call site to `bin-zsh <function>`
3. Update aliases and references

## Acceptance criteria

- [ ] All scripts migrated to autoloaded functions
- [ ] External call sites updated to use `bin-zsh`
- [ ] `zsh-lint` passes on all touched files
