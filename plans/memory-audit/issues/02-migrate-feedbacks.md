## TLDR

Add 4 feedback conventions to CLAUDE.md files as DO/DO NOT items.

## What to build

Add to `~/CLAUDE.md` (global):
- `- DO: Write multi-step debug commands to /tmp/oroshi/claude/scripts/ and run as a single call`

Add to oroshi `CLAUDE.md`:
- `- DO NOT: Use the Write tool on files containing nerd font glyphs (U+E000–U+F8FF) — Write silently strips them. Use Edit only, or git checkout to restore.`
- `- DO: Edit skill files under the worktree path, never via ~/.claude/skills/ symlinks (which point to main)`
- `- DO: For tested Node.js bin scripts in scripts/bin/, use a ZSH wrapper (no extension) + pure .js module (no shebang, exportable for vitest)`

## Acceptance criteria

- [ ] ~/CLAUDE.md contains the use_scripts convention
- [ ] Oroshi CLAUDE.md contains the 3 conventions
- [ ] Format matches existing `- DO:` / `- DO NOT:` style
