## Guidance

- All skill files live under `tools/ai/claude/config/skills/` (edit here, never via `~/.claude/skills/` symlinks)
- No tests — all changes are markdown prompt files
- No exceptions to the no-abbreviation rule for now
- `code-writer` is a fallback skill, not auto-loaded by language skills — rules must be explicitly duplicated
- Each language skill's `references/style.md` is referenced in its Step Refactor table
- zsh-writer already has the rule in `references/variables.md` — don't touch it

## Discoveries
