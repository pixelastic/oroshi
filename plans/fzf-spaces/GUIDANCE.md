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
