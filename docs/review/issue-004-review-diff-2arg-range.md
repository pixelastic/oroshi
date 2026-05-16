## PRD

[PRD — review-diff + review skill overhaul](./PRD.md)

## What to build

Add 2-argument range handling to `review-diff`. Diff directly between the two named refs using two-dot notation (no merge-base resolution — the user explicitly named both bounds).

Output: commit log between the two refs + stat + full diff, through `rtk`.

Add a bats test for this case to `review-diff.bats`.

## Acceptance criteria

- [ ] 2-arg range: stdout contains commits and a `diff --git` line scoped to the range between the two refs
- [ ] Bats test passes

## Blocked by

- issue-001 (script must exist before extending it)
