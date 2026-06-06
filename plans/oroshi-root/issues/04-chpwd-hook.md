## TLDR

Add a `chpwd` hook that switches `OROSHI_ROOT` and reloads PATH + fpath when entering or leaving an oroshi worktree mid-session.

## What to build

Add a function registered in `chpwd_functions` that fires on every directory change. It applies
the same worktree detection logic as `zshenv.zsh` (string check of `$PWD` against
`$OROSHI_WORKTREES_DIR`) to determine what `OROSHI_ROOT` should be in the new directory.

If the detected root differs from the current `$OROSHI_ROOT`, the hook:
1. Updates `OROSHI_ROOT` to the new root
2. Updates derived variables `ZSH_CONFIG_PATH` and `OROSHI_ZSH_AUTOLOAD`
3. Calls `oroshi-reload-path` with the new root
4. Calls `oroshi-reload-fpath` with the new root

If the root is unchanged (same worktree, same main), the hook is a no-op.

This covers three transitions:
- Normal → Worktree (entering a worktree via `cd` or jump)
- Worktree → Normal (leaving a worktree)
- Worktree A → Worktree B (jumping between two worktrees)

Verified manually: no automated tests.

## Acceptance criteria

- [ ] `cd`-ing into an oroshi worktree mid-session switches `OROSHI_ROOT` to that worktree root
- [ ] `cd`-ing back out restores `OROSHI_ROOT` to `~/.oroshi`
- [ ] Jumping between two oroshi worktrees switches correctly each time
- [ ] `cd` within the same context (no root change) does not trigger a reload
- [ ] `oroshi-reload-path` and `oroshi-reload-fpath` are called with the new root on context change
- [ ] The hook has no measurable impact on `cd` speed in normal (non-worktree) navigation
