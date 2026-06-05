## TLDR

Lint pass on scripts/bin/text tests (8 files).

## What to build

Run `bats-lint` on: `git-directory-dirty-count.bats`, `git-file-list-dirty-raw.bats`, `text-lines-to-words.bats`, `text-remove-empty-lines.bats`, `text-select-line.bats`, `text-split.bats`, `text-substring.bats`, `text-words-to-lines.bats`. Fix violations or encode rules.

## Behavioral Tests

**bats-lint violations resolved:**
- `bats-lint` exits 0 on each file

**Tests still pass:**
- `bats` exits 0 on each file

## Acceptance criteria

- [ ] `bats-lint` exits 0 on all 8 files
- [ ] `bats` passes on all 8 files
- [ ] Developer review sign-off
