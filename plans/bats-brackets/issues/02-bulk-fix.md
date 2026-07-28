## TLDR

Replace all `[ ]` with `[[ ]]` in existing `.bats` files across the repo.

## What to build

Run a sed replacement on all `.bats` files:
- `[ ` at line start (after optional whitespace) becomes `[[ `
- ` ]` at line end becomes ` ]]`

Scope: ~1,435 single-bracket assertions across ~161 files.

Verify by running `bats-lint` on all modified files — expect zero `noSingleBracket` violations.

## Acceptance criteria

- [ ] No `.bats` file in the repo contains a standalone `[ ]` assertion
- [ ] `bats-lint` reports zero `noSingleBracket` violations repo-wide
- [ ] Existing tests still pass on a representative sample of modified files
