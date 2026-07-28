## Guidance

- Script to modify: `scripts/bin/kitty/kitty-helper-claude-start`
- Test file to delete: `scripts/bin/kitty/__tests__/kitty-helper-claude-start.bats`
- Use `/zsh-writer` skill for the implementation
- Lint with `zsh-lint scripts/bin/kitty/kitty-helper-claude-start`
- No automated tests — manual verification only
- The script uses `set -e` (shebang script, not autoload)

## Discoveries
