## TLDR

Add `--repo` flag to `git-file-has-changed` for cross-repo change detection.

## What to build

Modify `git-file-has-changed` to accept `--repo` via `zparseopts`. When set, all `git diff` calls use `git -C "$repoPath" diff` instead of bare `git diff`. Defaults to current directory when `--repo` is not passed.

## Behavioral Tests

**Without `--repo`:**
- existing behavior unchanged (detects changes in current repo)

**With `--repo`:**
- detects changes in the specified repository, not the current directory

## Acceptance criteria

- [ ] `--repo` flag parsed and forwarded to `git diff` via `-C`
- [ ] Existing behavior preserved when `--repo` is omitted
- [ ] Tests pass in `git/file/__tests__/git-file-has-changed.bats`
