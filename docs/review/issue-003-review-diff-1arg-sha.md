## PRD

[PRD — review-diff + review skill overhaul](./PRD.md)

## What to build

Add 1-argument commit SHA handling to `review-diff`. When the arg is not a known branch (`git-branch-exists` returns non-zero), treat it as a commit SHA and show only that commit's changes.

Output: commit log + stat + full diff for that single commit, through `rtk`.

Add a bats test for this case to `review-diff.bats`.

## Acceptance criteria

- [ ] 1-arg SHA: stdout contains the commit message and a `diff --git` line scoped to that commit
- [ ] Bats test passes

## Blocked by

- issue-001 (script must exist before extending it)
