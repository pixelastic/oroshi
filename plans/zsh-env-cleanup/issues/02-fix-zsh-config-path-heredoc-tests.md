## TLDR

Replace `$ZSH_CONFIG_PATH` and hardcoded `~/.oroshi` paths inside bats heredoc test scripts with `$OROSHI_ROOT`-based paths.

## What to build

Two bats test files write inline zsh scripts via single-quoted heredocs (`<<'ZSCRIPT'`). Those scripts source files using the removed `$ZSH_CONFIG_PATH` variable, or via a hardcoded `~/.oroshi` path that bypasses the active worktree:

- `tools/term/zsh/config/prompt/__tests__/git.bats` — first 3 test heredocs use `$ZSH_CONFIG_PATH`; tests 4–5 use hardcoded `~/.oroshi/tools/term/zsh/config/prompt/git.zsh`. All should use `$OROSHI_ROOT`-based paths.
- `tools/term/zsh/config/functions/autoload/git/branch/__tests__/git-branch-color.bats` — 2 test heredocs use `$ZSH_CONFIG_PATH`. Replace with `$OROSHI_ROOT`-based paths.

Each inline script already sources `zshenv.zsh` as its first line, which exports `$OROSHI_ROOT`, so the replacement variable is available when the subsequent `source` calls execute.

The heredoc delimiter must remain single-quoted (`<<'ZSCRIPT'`) to avoid escaping the many runtime variables (`$result`, `$COLORS`, `$OROSHI_PROMPT_PARTS`, etc.) already present.

## Behavioral tests

Run both bats suites after the edit — all tests must pass.

## Acceptance criteria

- [ ] `git.bats` no longer references `$ZSH_CONFIG_PATH` or `~/.oroshi` inside heredocs
- [ ] `git-branch-color.bats` no longer references `$ZSH_CONFIG_PATH` inside heredocs
- [ ] `bats tools/term/zsh/config/prompt/__tests__/git.bats` passes
- [ ] `bats tools/term/zsh/config/functions/autoload/git/branch/__tests__/git-branch-color.bats` passes
- [ ] Both files pass `bats-lint`
