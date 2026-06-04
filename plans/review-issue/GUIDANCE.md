## Guidance

All three files being modified are LLM instruction documents (`.md` skill files), not code. There are no tests to write or run for this change. Verification is done by reading the modified files and confirming the contracts are correct.

**Files to modify:**
- `~/.claude/skills/review/references/specs-agent.md` — Step 2
- `~/.claude/skills/review/SKILL.md` — Step 1
- `~/.claude/skills/ralph/SKILL.md` — Step 4

**How to find skill paths:** Use `$OROSHI_ROOT` — skills live under `~/.claude/skills/` (user-level, not in this repo).

**Key constraint:** `ref:dirty` must map to "no args" when passed to `review-diff` — the script does not accept a `dirty` keyword. The translation happens in the review skill, not in review-diff.

**No linting, no tests** — these are markdown files only.

## Discoveries
