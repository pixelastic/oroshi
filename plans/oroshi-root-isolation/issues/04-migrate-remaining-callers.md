## TLDR

Migrate `post-commit.bats` and `kitty-helper-claude-start.bats` to `bats_run_zsh`, then remove deprecated helpers.

## What to build

Migrate two test files from deprecated helpers to `bats_run_zsh`:

`scripts/yarn/hooks/__tests__/post-commit.bats`:
- Replace `bats_run_script "$CURRENT"` with `bats_run_zsh "$CURRENT"` (3 occurrences).
- No other changes — function mocks via `bats_mock` are already compatible.

`scripts/bin/kitty/__tests__/kitty-helper-claude-start.bats`:
- Replace `bats_run_script "$SCRIPT"` with `bats_run_zsh "$SCRIPT"` (2 occurrences).
- No other changes.

Remove deprecated helpers from `tools/term/bats/config/helper`:
- Delete the `bats_run_function` function and its comment block.
- Delete the `bats_run_script` function and its comment block.

## Behavioral Tests

**post-commit exits 0 when plan-directory fails**
- Given `plan-directory` is mocked to return 1, when the post-commit hook runs, then exit status is 0

**post-commit deletes COMMIT_HINT.md when it exists**
- Given a plan directory with COMMIT_HINT.md, when the post-commit hook runs, then COMMIT_HINT.md is deleted

**kitty-helper-claude-start passes prompt arg to claude**
- Given a prompt argument, when the script runs, then claude is called with that argument

## Scaffolding Tests

**Deprecated helpers removed from bats helper**
- `bats_run_function` no longer exists in `tools/term/bats/config/helper`
- `bats_run_script` no longer exists in `tools/term/bats/config/helper`

## Acceptance criteria

- [ ] `bats post-commit.bats` passes with `bats_run_zsh`
- [ ] `bats kitty-helper-claude-start.bats` passes with `bats_run_zsh`
- [ ] `bats_run_function` removed from helper
- [ ] `bats_run_script` removed from helper
- [ ] No remaining references to `bats_run_function` or `bats_run_script` in any `.bats` file (except lint rule test strings if they mention it as a detected pattern)
