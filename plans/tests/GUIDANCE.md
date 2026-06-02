## Guidance

This plan modifies three skill files: `tdd`, `to-issues`, and `ralph`. All live in `tools/ai/claude/config/skills/`.

Issue 01 is the foundation — it creates the source of truth doc that issues 02 and 03 reference. Issues 02 and 03 are independent of each other and can be done in any order after 01.

No bats or vitest tests for any of these issues. Skill files are markdown — the modified files are the artifact. Do not attempt to write tests for skill content changes.

The `tdd/scaffolding.md` doc being created in issue 01 is the single source of truth. Issues 02 and 03 should reference its terminology and rules, not duplicate them.

## Discoveries

### Issue 04 — Rewrite tdd skill
- GUIDANCE.md hardcoded `/home/tim/.oroshi/` caused edits to land in main repo instead of worktree; fix: always resolve paths via `git-directory-root`, never use absolute paths from guidance docs.
- Spec agent gave false "Bad tests section not removed" finding because the diff sent to it was truncated; always send the full diff to review sub-agents.
