## TLDR

Clean up git domain scripts: migrate to autoloaded functions where possible, document, justify stayers.

## What to build

Scripts in scope (17):
- `git-commit-cancel` — undo last commit
- `git-commit-remove` — remove specific commit from history
- `git-commit-remove-all` — remove commits until specified one
- `git-commit-submodule` — commit submodule with chore() message
- `git-directory-root-bin` — binary wrapper for vim (already has `-bin` pattern)
- `git-file-resurrect` — restore deleted file from history
- `git-issue-create` — create GitHub issue
- `git-issue-list` — list repo issues
- `git-pullrequest-list` — list repo PRs
- `git-remote-remove` — remove git remotes
- `git-remote-rename` — rename git remote
- `git-remote-switch` — change branch remote
- `git-stash-apply` — apply and delete last stash
- `git-stash-create` — stash current files
- `git-submodule-list` — list submodules
- `git-submodule-remove` — remove submodules
- `git-submodule-create` (Ruby → ZSH rewrite)

Note: `git-directory-root-bin` is a legacy `-bin` wrapper (called by NeoVim). Migrate to autoloaded function, update NeoVim call site to `bin-zsh git-directory-root`, delete the wrapper.

For each script:
1. Rewrite from Ruby to ZSH if needed
2. Migrate to autoloaded function
3. If called from external context, update call site to `bin-zsh <function>`
4. Update aliases and references

## Acceptance criteria

- [ ] Ruby script rewritten to ZSH
- [ ] All scripts migrated to autoloaded functions
- [ ] External call sites updated to use `bin-zsh`
- [ ] Legacy `-bin` wrappers deleted
- [ ] `zsh-lint` passes on all touched files
