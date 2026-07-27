## Guidance

- Language: ZSH — use `zsh-writer` skill
- Testing: `bats <filepath>` — use `bats_run_zsh`, `bats_mock` pattern
- Linting: `zsh-lint <filepath>` for scripts, `bats-lint <filepath>` for tests
- Production files:
  - `scripts/bin/kitty/kitty-helper-claude-start`
  - `scripts/bin/ai/sidequest/sidequest-end`
- Test files:
  - `scripts/bin/kitty/__tests__/kitty-helper-claude-start.bats`
  - `scripts/bin/ai/sidequest/__tests__/sidequest-end.bats`
- `kitty-window-toggle-claude` also calls `kitty-helper-claude-start` with no args — must remain unaffected

## Discoveries
