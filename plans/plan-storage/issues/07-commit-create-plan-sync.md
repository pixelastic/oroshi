## TLDR

Make `git-commit-create` auto-commit the dirty plan repo after a successful worktree commit.

## What to build

Modify `tools/term/zsh/config/functions/autoload/git/commit/git-commit-create`:

After the `git commit` succeeds (exit code 0):

1. Determine the target repo path (from `--repo` flag or cwd).
2. Resolve plan dir for that repo via `plan-directory "$repoPath"`. If no plan exists, done.
3. Check if the plan repo has dirty files: `git -C "$planDir" status --porcelain`.
4. If dirty, stage all: `git -C "$planDir" add -A`.
5. Commit with the same message used for the worktree commit: `git -C "$planDir" commit -m "$commitMessage"`.

If the worktree commit fails or is aborted (non-zero exit), skip the plan commit entirely — let the existing error propagate.

The plan commit should be silent (no output) unless it fails.

## Behavioral Tests

**git-commit-create.bats** (extend existing):
- Successful worktree commit with dirty plan repo → plan repo committed with same message
- Successful worktree commit with clean plan repo → no plan commit (no error)
- Successful worktree commit with no associated plan → no plan commit (no error)
- Aborted/failed worktree commit → plan repo untouched
- `--repo` targeting: plan association follows target repo, not cwd

## Acceptance criteria

- [ ] Dirty plan repo auto-committed after successful worktree commit
- [ ] Commit message matches worktree commit message
- [ ] No plan commit on worktree commit failure/abort
- [ ] Works with `--repo` flag
- [ ] Silent on success, errors propagated on failure
