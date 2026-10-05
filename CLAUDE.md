## Code

- DO NOT: Use the Write tool on files containing nerd font glyphs (U+E000–U+F8FF)
    - Write silently strips them. Use Edit only, or git checkout to restore.
    - [Source](https://github.com/anthropics/claude-code/issues/70301)

## Skills

- Never edit `~/.claude/skills/` directly.
- Resolve the symlink to find the real path inside `~/.oroshi/`
- If in a worktree, replace the `~/.oroshi/` prefix with the current worktree root (`git rev-parse --show-toplevel`)
