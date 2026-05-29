## TLDR

Write permanent BATS tests locking down the current 7-field output format of `git-branch-list-raw` before any changes are made.

## What to build

Add a `git-branch-list-raw.bats` test file in the branch `__tests__/` directory. Tests run against the live function output and assert on the observable format: number of `▮`-delimited fields per line, that field 1 is a non-empty branch name, that field 5 is the combined upstream track string (e.g. `[ahead 2]` or empty), field 6 is a non-empty relative date string, and field 7 is the commit message subject.

Tests must pass green on the current code with no changes to the implementation. They exist to catch regressions when the format is broken in issue 02.

## Acceptance criteria

- [ ] `git-branch-list-raw.bats` exists in the branch `__tests__/` directory
- [ ] Tests pass on current code with `bats git-branch-list-raw.bats`
- [ ] Each output line has exactly 7 `▮`-delimited fields
- [ ] Field 1 is a non-empty string (branch name)
- [ ] Field 5 is the combined `%(upstream:track)` format (e.g. `[ahead N]`, `[behind N]`, or empty)
- [ ] Field 6 is a non-empty relative date string
- [ ] Field 7 is a non-empty commit message subject
