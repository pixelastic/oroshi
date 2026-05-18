## PRD

`docs/context-badge/PRD.md`

## What to build

Add `--zsh` flag support to `context-badge`.

When `--zsh` is passed, the function sets `OROSHI_IS_PROMPT=1` internally so that downstream rendering functions (`project-colorize`, `colorize`) emit zsh prompt escape codes (`%K{}`, `%F{}`) instead of raw ANSI sequences. Without `--zsh` the behavior is unchanged (raw ANSI).

Extend the existing BATS tests with two new cases:
- `context-badge <path> --zsh` → output contains `%K{` codes
- `context-badge <path>` (no flag) → output does NOT contain `%K{` codes

## Acceptance criteria

- [ ] `--zsh` flag causes output to contain `%K{` zsh prompt color codes
- [ ] Without `--zsh`, output contains raw ANSI escape sequences and no `%K{` codes
- [ ] All other behavior (badge content, worktree detection) unchanged
- [ ] BATS tests cover both flag and no-flag cases

## Blocked by

- issue-002 (`context-badge` core must exist first)
