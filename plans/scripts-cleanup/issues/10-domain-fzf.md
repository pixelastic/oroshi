## TLDR

Clean up FZF domain scripts: migrate to autoloaded functions where possible, document, justify stayers.

## What to build

Scripts in scope (5):
- `ctrl-shift-o` — fuzzy search directories
- `fzf-apt-packages` — fuzzy search apt packages
- `fzf-git-files-dirty-stageable`
- `fzf-git-files-dirty`
- `fzf-js-test` — fuzzy pick JS test file

Note: FZF scripts in the "alive" list (ctrl-p, ctrl-shift-p, ctrl-g, ctrl-shift-g) are called by NeoVim and must stay as scripts. The 5 scripts here need evaluation.

For each script:
1. Check if called from non-ZSH context
2. Migrate to autoloaded function or justify as script
3. Ensure doc comment present
4. Update aliases and references

## Acceptance criteria

- [ ] Each script migrated to autoloaded function or has `# Script because:`
- [ ] All scripts/functions have doc comments
- [ ] `zsh-lint` passes on all touched files
