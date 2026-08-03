## Guidance

- All functions are ZSH autoload functions — use `/zsh-writer` skill
- Test with `bats <filepath>`
- Lint with `zsh-lint <filepath>` and `bats-lint <filepath>`
- The `▮` character is the project-wide raw output separator — use it in all `-raw` function output
- Prior art for git file tests: `tools/term/zsh/config/functions/autoload/git/file/__tests__/git-file-list-dirty-raw.bats`
- Prior art for fzf tests: `scripts/bin/fzf/__tests__/fzf-git-files-dirty-stageable.bats`
- `git-status-raw` goes in `tools/term/zsh/config/functions/autoload/git/`
- The three `-raw` filter functions are in `tools/term/zsh/config/functions/autoload/git/file/`
- `core.quotePath=false` must be passed per-command (`git -c`), never set globally
- Renames: `git status --porcelain` shows `old -> new` — split on ` -> ` to extract both paths

## Discoveries

### Issue 01 — git-status-raw
- `core.quotePath=false` prevents C-style escaping of non-ASCII chars but git porcelain still wraps paths containing spaces in double quotes — must strip them with `${filePath#\"}` / `${filePath%\"}`

### Issue 02 — refactor raw filters
- `git-status-raw` now outputs `filepath▮X▮Y` (renames: `filepath▮X▮Y▮oldpath`) — preserves both columns so filter functions can choose which to use
- All three `-raw` filter functions are thin filters over `git-status-raw` — they resolve/filter the X/Y columns and emit `filepath▮STATUS`
- `MOCK_OROSHI_WORKTREES_DIR` overrides `OROSHI_WORKTREES_DIR` in zshenv-host.zsh — tests exporting it must call `bats_disable_worktree_aware` to prevent OROSHI_ROOT from falling back to `~/.oroshi`
