## TLDR

Update `calling-commands.md` to reference `helper-list-raw` for helper discovery, replacing the `!tree` dump.

## What to build

Edit `tools/ai/claude/config/skills/zsh-writer/references/calling-commands.md`:

- Keep the existing examples table as-is
- Replace the `!tree` line and surrounding text with guidance to use `helper-list-raw <domain>` for discovering helpers
- Briefly explain the output format (name, description, filepath) so agents know what to expect

## Acceptance criteria

- [ ] `!tree` reference removed
- [ ] `helper-list-raw` usage documented
- [ ] Examples table preserved
- [ ] Agent knows to call `helper-list-raw` before falling back to porcelain
