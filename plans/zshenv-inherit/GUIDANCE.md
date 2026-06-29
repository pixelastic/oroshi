## Guidance

- **Test file**: `tools/term/zsh/config/__tests__/zshenv-host.bats`
- **Run tests**: `bats tools/term/zsh/config/__tests__/zshenv-host.bats`
- **Lint**: `bats-lint tools/term/zsh/config/__tests__/zshenv-host.bats`
- **Helper cleanup file**: `tools/term/bats/config/__tests__/helper.bats`
- **Glossary**: `tools/term/bats/GLOSSARY.md` (Worktree-aware definition)
- **cd in test body**: always do `cd` in the bash test body, never inside the `bats_run_zsh` argument — functions autoload from fpath set at zsh startup, so cd inside the zsh command doesn't affect function resolution
- **MOCK_OROSHI_WORKTREES_DIR**: export inline per test, never in `setup()` — setting it globally breaks existing tests
- **Worktree creation**: `git -C "$OROSHI_ROOT" worktree add --detach "$BATS_TMP_DIR/worktrees/oroshi--bats-test"`
- **Worktree cleanup**: `git worktree prune` in teardown, after `bats_cleanup`
- **Assertions**: Test 01 against `$HOME/.oroshi`, Test 02 against custom string, Test 03 against `$OROSHI_ROOT`
- **Prior art**: existing tests in zshenv-host.bats use `run_bare_zsh` (unit); new tests use `bats_run_zsh` (integration)

## Discoveries

### Issue 03 — disable worktree-aware
- `~/.zshenv` symlinks to `$HOME/.oroshi` (main repo) — the disable guard must be applied to the main repo's `zshenv-host.zsh` directly, not just the worktree's copy.
- `autoload` marks are per-process, not inherited via env. Skipping fpath reload when disabled breaks functions (127). PATH inheritance works because PATH is a standard env var.
- Planning comments referenced by issue 03 (lines 13-28 of helper.bats) don't exist in the current file — likely removed in a prior refactor.
