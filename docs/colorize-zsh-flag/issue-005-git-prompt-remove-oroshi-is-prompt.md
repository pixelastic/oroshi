## PRD

[colorize-zsh-flag/PRD.md](./PRD.md)

## What to build

Remove `OROSHI_IS_PROMPT` from `git.zsh` and from `colorize`.

Replace the 3 calls in `git.zsh`:
- `$(OROSHI_IS_PROMPT=1 git-branch-colorize --with-icon)` → `$(git-branch-colorize --with-icon --zsh)`
- `$(OROSHI_IS_PROMPT=1 git-tag-colorize --with-icon)` → `$(git-tag-colorize --with-icon --zsh)`
- `$(OROSHI_IS_PROMPT=1 git-remote-colorize --with-icon)` → `$(git-remote-colorize --with-icon --zsh)`

Then remove the `[[ "$OROSHI_IS_PROMPT" == 1 ]]` backward-compat check from `colorize`.

## Acceptance criteria

- [ ] `git.zsh` contains no occurrence of `OROSHI_IS_PROMPT`
- [ ] `colorize` contains no occurrence of `OROSHI_IS_PROMPT`
- [ ] The zsh prompt still correctly displays branch, tag, and remote in zsh prompt format

## Blocked by

- issue-002 (`git-branch-colorize` must accept `--zsh`)
- issue-003 (`git-tag-colorize` must accept `--zsh`)
- issue-004 (`git-remote-colorize` must accept `--zsh`)
