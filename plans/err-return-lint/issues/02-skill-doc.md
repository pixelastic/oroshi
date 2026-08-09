## TLDR

Add `2>/dev/null` guidance to the `zsh-writer` skill's `calling-commands.md`.

## What to build

Add a short section to `tools/ai/claude/config/skills/zsh-writer/references/calling-commands.md` explaining:
- Do not add `2>/dev/null` inside `$(...)` by default
- Only add it when the called command is known to write to stderr (external binaries like `git`, `curl`, `kitty-remote`)
- Autoloaded project helpers do not write to stderr — do not suppress

Keep it concise — 3-4 lines max, matching the doc's existing style.

## Acceptance criteria

- [ ] Section added to `calling-commands.md`
- [ ] Guidance is clear and actionable
