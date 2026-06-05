## TLDR

Lint pass on lua-lint tests and remaining misc tests (11 files).

## What to build

Run `bats-lint` on lua-lint tests (lua-lint-custom, lua-lint-selene, lua-test-path, rule-no-vim-deepcopy) and remaining misc files (wav2txt-openai, git-commit-is-before, better-rm, epub2md, oroshi-reload-functions, plan-list-raw, is-zsh). Fix violations or encode rules.

## Behavioral Tests

**bats-lint violations resolved:**
- `bats-lint` exits 0 on each file

**Tests still pass:**
- `bats` exits 0 on each file

## Acceptance criteria

- [ ] `bats-lint` exits 0 on all 11 files
- [ ] `bats` passes on all 11 files
- [ ] Developer review sign-off
