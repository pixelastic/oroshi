## Guidance

### Testing
- Run BATS tests: `bats <filepath>`
- Run ZSH lint: `zshlint <filepath>`
- Scaffold tests use `.scaffold.bats` extension — delete before committing

### Key files
- `git-branch-list-raw` — data source for branch list (modified in issue 02)
- `git-branch-colorize` — branch name rendering (modified in issue 04)
- `git-branch-list` — main orchestrator (modified in issues 03 and 05)
- `complete-git-branches-local` — tab-completion consumer (modified in issue 02)
- `git-worktree-list-raw` — worktree data source, read-only in this PRD

### Prior art for tests
- Existing BATS tests: `git/branch/__tests__/git-branch-colorize.bats`
- Mock pattern: `bats_mock`, `bats_run_function` helpers from `bats_load_library 'helper'`
- `bats_git_dir 'repo'` for a real git repo in tests

### UTF-8 / powerline character safety
The powerline right-arrow (U+E0B0) is invisible in `Read` tool output and stripped silently by `Write`. Always:
1. Define it as a named local variable at the top of the function
2. Use `Edit` (never `Write`) when touching files that contain this character
3. Reference the variable everywhere — never inline the literal

### Column layout (issues 03–05)
Same positions for all rows:
- Col 1: pointer
- Col 2: branch name
- Col 3: dirty count (worktree) OR remote name if non-default (non-worktree)
- Col 4: ahead vs main (worktree) OR ahead vs remote (non-worktree)
- Col 5: behind vs main (worktree) OR behind vs remote (non-worktree)
- Col 6: relative date
- Col 7: short commit hash
- Col 8: commit message

### Worktree colors
- Background: `COLOR_ORANGE_7` (#c2410c)
- Foreground: `COLOR_ORANGE_1` (#ffedd5)
- Pattern from `context-badge`: `colorize " $name " ORANGE_1 ORANGE_7` + `colorize "$sep" ORANGE_7`

### Field order in git-branch-list-raw (after issues 02–03)
`branch▮hash▮remoteName▮remoteBranch▮ahead▮behind▮date▮message` (8 fields)
Field 4 is the branch name only (e.g. `main`), not the full ref — `refs/heads/` prefix is stripped in the raw function.

## Discoveries

### Issue 03 — Integrate new columns branch list
- Storing `▮`-separated values as associative array values silently fails in zsh; use 4 separate arrays (`worktrees`, `worktreeDirty`, `worktreeAhead`, `worktreeBehind`) instead of one packed map.
- `bats_mock` serializes bash functions via `declare -f`; the ▮ character survives the round-trip correctly when used directly (not via `\u25ae` escape in awk `-F`).

### Issue 02 — Split ahead/behind raw
- `%(upstream:ahead)` and `%(upstream:behind)` are not valid format atoms in git 2.43 — use `%(upstream:track)` + sed parsing instead to extract numeric values.
- `git-branch-list` needs `remoteDistance` reconstructed as `"ahead $aheadCount, behind $behindCount"` to stay compatible with `git-distance-colorize` until issues 03–05 refactor the display.
