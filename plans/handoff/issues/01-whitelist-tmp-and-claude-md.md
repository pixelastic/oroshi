## TLDR

Whitelist `Write(/tmp/oroshi/claude/*)` in settings and point CLAUDE.md at the ephemeral scripts folder.

## What to build

Two config changes that establish `/tmp/oroshi/claude/` as the single ephemeral workspace for all Claude-generated files:

1. Add `Write(/tmp/oroshi/claude/*)` to the `permissions.allow` array in `~/.claude/settings.json`. This eliminates the approval prompt whenever Claude writes to any subdirectory of that tree.

2. Update the throw-away scripts convention in `~/CLAUDE.md`: replace the persistent path (`~/local/tmp/claude/`) with the ephemeral one (`/tmp/oroshi/claude/scripts`).

## Acceptance criteria

- [ ] `settings.json` contains `Write(/tmp/oroshi/claude/*)` in `permissions.allow`
- [ ] `CLAUDE.md` references `/tmp/oroshi/claude/scripts` (not `~/local/tmp/claude`) for one-off scripts
