## TLDR

Delete all memory directories across all projects and disable auto-memory globally.

## What to build

1. Delete all memory directories: `rm -rf ~/.claude/projects/*/memory/`
2. Add `"autoMemoryEnabled": false` to `~/.claude/settings.json`

## Acceptance criteria

- [ ] No `memory/` directory exists under `~/.claude/projects/`
- [ ] `~/.claude/settings.json` contains `"autoMemoryEnabled": false`
- [ ] Claude Code no longer auto-saves memories in new conversations
