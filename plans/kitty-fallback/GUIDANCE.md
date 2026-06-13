## Guidance

This plan fixes `kitty-helper-claude-start` so both code paths fall back to zsh after Claude exits.

**Files to modify:**
- `scripts/bin/kitty/kitty-helper-claude-start` — the script
- `scripts/bin/kitty/__tests__/kitty-helper-claude-start.bats` — the tests

**Testing:**
- Run bats tests: `bats scripts/bin/kitty/__tests__/kitty-helper-claude-start.bats`
- Lint the script: `zsh-lint scripts/bin/kitty/kitty-helper-claude-start`
- Lint the test file: `bats-lint scripts/bin/kitty/__tests__/kitty-helper-claude-start.bats`

**Conventions:**
- Use `bats_mock` for all command mocking — no manual fake-binary blocks
- All test variables go in `setup()`, not at file top level
- Use `[[ $isXxx == "1" ]]` for flag boolean tests
- `|| true` to absorb exit codes; plain `zsh` (no `exec`) as fallback

**Prior art:**
- `kitty-helper-claude-start.bats` — existing mock patterns for `git-directory-root` and `claude`
- `kitty-tab-create.bats` — another kitty helper test using `bats_mock`

## Discoveries

### Issue 01 — kitty-helper-claude-start fallback

- `bats_run_zsh` only takes `$1` as command string — extra positional args are silently ignored; pass script args inline: `bats_run_zsh "$CURRENT arg1 arg2"`.
- `bats_mock zsh` works for plain `zsh` calls but NOT for `exec zsh` (exec bypasses function lookup); the refactor from `exec zsh` to plain `zsh` was required to make the mock work.
- The original test 2 was already broken (arg not passed via `bats_run_zsh "$CURRENT" "arg"`) — fixed as part of this issue.
