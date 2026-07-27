## TLDR

Four new `git-github-*` helpers for repo archival and description management.

## What to build

New helpers in `tools/term/zsh/config/functions/autoload/git/github/`:

- **`git-github-repo-is-archived <owner/repo>`** — check `isArchived` via `gh api repos/<owner/repo> --jq '.archived'`. Returns exit code 0 (archived) or 1 (not archived).
- **`git-github-repo-description <owner/repo>`** — get description via `gh api repos/<owner/repo> --jq '.description'`. Outputs the description string.
- **`git-github-repo-description-set <owner/repo> <description>`** — update description via `gh api -X PATCH repos/<owner/repo> -f description="<description>"`.
- **`git-github-repo-archive <owner/repo>`** — archive via `gh repo archive <owner/repo> --yes`.

All are thin wrappers around `gh` commands.

## Acceptance criteria

- [ ] All four helpers created in the git/github autoload directory
- [ ] Each follows existing `git-github-*` pattern (see `git-github-repo-exists` for reference)
- [ ] Each uses `setopt local_options err_return`
- [ ] No tests (thin wrappers with no parsing logic)
