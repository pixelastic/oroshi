## Guidance

- File to edit: `tools/ai/claude/config/skills/js-writer/references/testing.md`
- Do NOT edit via `~/.claude/skills/` symlink — edit the worktree copy only
- No tests — this is a skill reference file, not executable code
- Target: under 120 lines total
- Prior art for filesystem test pattern: `~/local/www/projects/emulation/lib/remote/__tests__/push.js`
- Variable naming convention: `testDirectory` (verified across firost, keyleth, aberlaas, gilmore)
- `tmpDirectory()` is synchronous — returns a path string, no `await` needed

## Discoveries
