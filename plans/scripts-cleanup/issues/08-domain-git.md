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

Note: `git-directory-root-bin` is the exemplar of the `-bin` wrapper pattern. It must stay as a script (called by NeoVim).

For each script:
1. Rewrite from Ruby to ZSH if needed
2. Check if called from non-ZSH context
3. Migrate to autoloaded function or justify as script
4. Ensure doc comment present
5. Update aliases and references

## Acceptance criteria

- [ ] Ruby script rewritten to ZSH
- [ ] Each script migrated to autoloaded function or has `# Script because:`
- [ ] All scripts/functions have doc comments
- [ ] `zsh-lint` passes on all touched files
