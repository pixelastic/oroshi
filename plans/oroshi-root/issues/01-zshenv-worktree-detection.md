## TLDR

Detect oroshi worktree from `$PWD` at shell startup and set `OROSHI_ROOT` accordingly.

## What to build

In `zshenv.zsh`, before `OROSHI_ROOT` is assigned its default (`~/.oroshi`), add a fast
string-check block: if `$PWD` starts with `$OROSHI_WORKTREES_DIR`, extract the worktree root
(the immediate subdirectory under `$OROSHI_WORKTREES_DIR`) and set `OROSHI_ROOT` to it.
The derived variables `ZSH_CONFIG_PATH` and `OROSHI_ZSH_AUTOLOAD` are already computed from
`OROSHI_ROOT` on the lines that follow, so they update automatically.

Add a short comment above the block noting that `git-directory-is-worktree` exists but is too
costly to invoke on every shell startup.

Since `.zshenv` is sourced for every new zsh process (interactive, `zsh -c`, pre-commit
subshells, NeoVim subshells), this single change makes every subprocess that runs from inside
a worktree directory automatically resolve tools from that worktree.

## Acceptance criteria

- [ ] Opening a terminal whose `$PWD` is inside an oroshi worktree sets `OROSHI_ROOT` to that worktree root
- [ ] `OROSHI_ROOT` stays `~/.oroshi` when `$PWD` is outside `$OROSHI_WORKTREES_DIR`
- [ ] `ZSH_CONFIG_PATH` and `OROSHI_ZSH_AUTOLOAD` reflect the new `OROSHI_ROOT` automatically
- [ ] No subprocess is spawned during the detection (pure string check)
- [ ] A short comment explains why the simpler string check is used instead of `git-directory-is-worktree`
