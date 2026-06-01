## Guidance

This plan modifies three skill files: `tdd`, `to-issues`, and `ralph`. All live in `/home/tim/.oroshi/tools/ai/claude/config/skills/`. The skills are symlinked from `~/.claude/skills/` — edit the originals in `.oroshi`, not the symlinks.

Issue 01 is the foundation — it creates the source of truth doc that issues 02 and 03 reference. Issues 02 and 03 are independent of each other and can be done in any order after 01.

No bats or vitest tests for any of these issues. Skill files are markdown — the modified files are the artifact. Do not attempt to write tests for skill content changes.

The `tdd/scaffolding.md` doc being created in issue 01 is the single source of truth. Issues 02 and 03 should reference its terminology and rules, not duplicate them.

## Discoveries
