## TLDR

Lint pass on fzf function tests (4 files).

## What to build

Run `bats-lint` on fzf tests: `fzf-claude-sessions-preview.bats`, `fzf-claude-sessions-source-no-query.bats`, `fzf-fs-shared-preview-header.bats`, `fzf-prompt-directory.bats`. Fix violations or encode rules.

## Behavioral Tests

**bats-lint violations resolved:**
- `bats-lint` exits 0 on each file

**Tests still pass:**
- `bats` exits 0 on each file

## Acceptance criteria

- [ ] `bats-lint` exits 0 on all 4 files
- [ ] `bats` passes on all 4 files
- [ ] Developer review sign-off
