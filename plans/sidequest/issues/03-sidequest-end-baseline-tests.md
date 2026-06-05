## TLDR

Write tests covering the current behavior of `sidequest-end` before any modification.

## What to build

Write a bats test file for `sidequest-end` in its current state. These tests establish a safety net before the script is modified in issue 05. Mock `clipboard-write` as an immediate collaborator.

## Behavioral Tests

**Error handling**
- exits with an error when called with no argument
- exits with an error when the given file does not exist

**Happy path**
- calls `clipboard-write` with `@<filepath>` when given a valid file

## Acceptance criteria

- [ ] Test file exists at `scripts/bin/ai/sidequest/__tests__/sidequest-end.bats`
- [ ] All tests pass against the current (unmodified) `sidequest-end`
- [ ] `clipboard-write` is mocked via `bats_mock`
