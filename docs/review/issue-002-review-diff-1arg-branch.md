## PRD

[PRD — review-diff + review skill overhaul](./PRD.md)

## What to build

Add 1-argument branch handling to `review-diff`. When the arg is a known branch (detected via `git-branch-exists`), two modes apply:

- **Self-review** (arg == current branch): find base via `git-branch-parent`, diff from base to HEAD. Shows what this branch has done since forking.
- **External review** (arg != current branch): diff from HEAD to the passed branch. Shows what that branch would bring in.

Output per case: commit log + stat + full diff, through `rtk`. No section headers.

Add bats tests for both modes to `review-diff.bats`.

## Acceptance criteria

- [ ] 1-arg branch, self-review: stdout contains the feature branch commit and a `diff --git` line
- [ ] 1-arg branch, external review: stdout contains the feature commit and a `diff --git` line; commits exclusive to the current branch are absent
- [ ] Both bats tests pass

## Blocked by

- issue-001 (script must exist before extending it)
