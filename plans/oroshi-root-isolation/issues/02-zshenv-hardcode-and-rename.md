## TLDR

Hardcode `OROSHI_ROOT` and `OROSHI_TMP_FOLDER` in zshenv, rename the worktrees escape hatch to `OROSHI_WORKTREES_DIR_MOCK`.

## What to build

In `tools/term/zsh/config/zshenv.zsh`:
- Replace `export OROSHI_ROOT="${OROSHI_ROOT:-$HOME/.oroshi}"` with `export OROSHI_ROOT="$HOME/.oroshi"` (hardcoded, no escape hatch).
- Replace `export OROSHI_WORKTREES_DIR="${OROSHI_WORKTREES_DIR:-$HOME/local/www/worktrees}"` with `export OROSHI_WORKTREES_DIR="${OROSHI_WORKTREES_DIR_MOCK:-$HOME/local/www/worktrees}"` (renamed to make test-only purpose explicit).
- Replace `export OROSHI_TMP_FOLDER="${OROSHI_TMP_FOLDER:-$HOME/local/tmp/oroshi}"` with `export OROSHI_TMP_FOLDER="$HOME/local/tmp/oroshi"` (hardcoded, no test uses it).
- Remove or update the comment "The following paths are overridable by tests" — only OROSHI_WORKTREES_DIR retains a mock escape hatch.

Update `tools/term/zsh/config/__tests__/zshenv.bats`:
- Replace all `export OROSHI_WORKTREES_DIR=` with `export OROSHI_WORKTREES_DIR_MOCK=` in inline scripts.
- Rewrite the test "OROSHI_ROOT is unchanged when PWD is outside OROSHI_WORKTREES_DIR": since zshenv now hardcodes OROSHI_ROOT, this test should verify that OROSHI_ROOT equals `$HOME/.oroshi` when PWD is outside worktrees (not that a pre-set value is preserved). Fake HOME to control the expected path.

Update 4 other test files — rename `export OROSHI_WORKTREES_DIR=` to `export OROSHI_WORKTREES_DIR_MOCK=`:
- `tools/term/zsh/config/functions/autoload/git/worktree/__tests__/git-worktree-create.bats` (setup)
- `scripts/bin/text/__tests__/git-directory-dirty-count.bats` (individual tests)
- `scripts/bin/text/__tests__/git-file-list-dirty-raw.bats` (individual tests)
- `scripts/bin/ai/sidequest/__tests__/sidequest.bats` (setup)

`git-worktree-list.bats` only reads `$OROSHI_WORKTREES_DIR` in assertions — not impacted (OROSHI_WORKTREES_DIR is still exported by zshenv).

## Behavioral Tests

**zshenv sets OROSHI_ROOT to worktree root when PWD is in worktrees dir**
- Given OROSHI_WORKTREES_DIR_MOCK points to a fake worktrees directory and PWD is inside a worktree there, when zshenv is sourced, then OROSHI_ROOT equals the worktree root

**zshenv defaults OROSHI_ROOT to $HOME/.oroshi when outside worktrees**
- Given PWD is outside the worktrees directory, when zshenv is sourced, then OROSHI_ROOT equals `$HOME/.oroshi`

## Acceptance criteria

- [ ] `OROSHI_ROOT` is hardcoded in zshenv (no `${:-}`)
- [ ] `OROSHI_TMP_FOLDER` is hardcoded in zshenv (no `${:-}`)
- [ ] `OROSHI_WORKTREES_DIR` reads from `OROSHI_WORKTREES_DIR_MOCK` with a `${:-}` fallback
- [ ] `bats zshenv.bats` passes
- [ ] `bats git-worktree-create.bats` passes
- [ ] `bats git-directory-dirty-count.bats` passes
- [ ] `bats git-file-list-dirty-raw.bats` passes
- [ ] `bats sidequest.bats` passes
