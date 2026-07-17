## TLDR

Make `kitty-reload` write the source path (worktree or main) into the Reload Beacon.

## What to build

Modify `scripts/bin/kitty/kitty-reload` to:

1. Call `kitty-pwd` to get the cwd of the focused window
2. Test with `git-worktree-is-oroshi` (from that cwd) whether the cwd is inside
   an oroshi worktree
3. If yes: find the worktree root and write it into the Reload Beacon file
4. If no: write `$OROSHI_ROOT` into the Reload Beacon file

The Reload Beacon is no longer an empty file — it always contains a path. This
path tells `reload.py` where to load modules from.

## Behavioral Tests

**Beacon content when in an oroshi worktree:**
- writes the worktree root path into the beacon

**Beacon content when NOT in an oroshi worktree:**
- writes $OROSHI_ROOT into the beacon

**Beacon content when kitty-pwd fails:**
- writes $OROSHI_ROOT into the beacon (fallback)

**Still triggers kitty-redraw:**
- calls kitty-redraw after writing the beacon

## Acceptance criteria

- [ ] Beacon file contains worktree root when focused window is in an oroshi worktree
- [ ] Beacon file contains `$OROSHI_ROOT` when focused window is not in an oroshi worktree
- [ ] Beacon file contains `$OROSHI_ROOT` when `kitty-pwd` fails
- [ ] `kitty-redraw` is still called after writing the beacon
- [ ] Bats tests mock `kitty-pwd`, `git-worktree-is-oroshi`, and `kitty-redraw`
