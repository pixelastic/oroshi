## TLDR

Rewrite `sidequest/SKILL.md` to follow the canonical skill-writer template format.

## What to build

The current `SKILL.md` is flat prose. Rewrite it with the full structured format:

1. `description:` starts with "Use when…"
2. `## Overview` — one sentence goal
3. `## Core Workflow` with sequential named steps, each having `**Goal:**` and `**Exit criterion:**`:
   - Step 1 — Derive slug (from argument if provided, else from conversation content)
   - Step 2 — Write document (create dir, write to `/tmp/oroshi/claude/sidequests/<slug>.md`)
   - Step 3 — Finalize (run `sidequest-end <path>`)
4. `## Common Rationalizations` — short table, 2–3 rows max
5. `## Checklist` — 3–5 items, one per step

Keep all existing behavioral instructions intact (no duplication of artifacts, suggest skills, tailor to argument).

## Acceptance criteria

- [ ] `description:` starts with "Use when…"
- [ ] `## Overview` section present
- [ ] `## Core Workflow` with at least 3 steps, each with `**Goal:**` and `**Exit criterion:**`
- [ ] `## Common Rationalizations` table present
- [ ] `## Checklist` present
- [ ] All behavioral instructions from current SKILL.md preserved
