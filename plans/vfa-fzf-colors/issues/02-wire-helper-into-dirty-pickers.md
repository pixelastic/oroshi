## TLDR

Replace flat git-status coloring in both dirty file pickers with the new `fzf-colorize-git-status-path` helper.

## What to build

Modify `fzf-source()` in two FZF Scripts:
- `scripts/bin/fzf/fzf-git-files-dirty-stageable` (used by `vfa` ctrl-p)
- `scripts/bin/fzf/fzf-git-files-dirty` (used by `vfrevert` ctrl-p)

In both scripts:
- Source `fzf-colorize-git-status-path.zsh` at the top (alongside other helpers)
- In `fzf-source()`, replace the `colorize "$filepath" $COLORS[git-*]` calls with `fzf-colorize-git-status-path "$filepath" "$gitStatus"` and use `$REPLY` as the display column
- The first column (raw filepath for postprocessing) stays unchanged
- Remove the now-unnecessary `colors-load-definitions` call from `fzf-source()` if it's no longer directly used there (the helper loads it internally via `fzf-colorize-path`)

## Scaffolding Tests

Existing `--source` tests in `fzf-git-files-dirty.bats` already verify file presence in output — they should continue to pass since the filepath is still in the output (now with prefix and ANSI codes).

Extend tests to verify:
- `--source` for a modified file contains `~` prefix
- `--source` for an added/untracked file contains `+` prefix
- `--source` for a deleted file contains `-` prefix

Add `--source` tests to `fzf-git-files-dirty-stageable.bats` (currently only has `--preview` tests):
- `--source` for a modified file contains `~` prefix and filename

## Acceptance criteria

- [ ] Both pickers use `fzf-colorize-git-status-path` in `fzf-source()`
- [ ] No more flat `colorize "$filepath" $COLORS[git-*]` calls in either picker
- [ ] First column (raw filepath) unchanged — postprocessing unaffected
- [ ] Existing tests still pass
- [ ] New `--source` tests verify prefix presence
- [ ] `bats-lint` and `zsh-lint` pass on modified files
