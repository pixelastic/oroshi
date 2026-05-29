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

### Field order in git-branch-list-raw (after issue 02)
`branch▮hash▮remoteName▮remoteBranchRef▮ahead▮behind▮date▮message` (8 fields)
Consistent with `git-worktree-list-raw` which also uses ahead before behind.

## Discoveries
