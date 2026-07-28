## TLDR

Create the merged `/plan` skill combining PRD and Issues workflows into one continuous flow.

## What to build

Create `tools/ai/claude/config/skills/plan/SKILL.md` with 7 steps:

1. Explore codebase + glossary
2. Sketch modules, get user confirmation (modules + test scope)
3. Write PRD.md + COMMIT_HINT.md (after user approves PRD content). Call `plan-start` for worktree + paths.
4. Draft vertical slices (no re-exploration)
5. Confirm slices with user
6. Write issues/, state.json, GUIDANCE.md
7. Ask user permission, run `plan-end`, tell user to stop and run ralph

Copy reference templates into `plan/references/`:
- `prd-md.md` (from prd skill)
- `issues-XX-slug.md` (from issues skill)
- `state-json.md` (from issues skill)
- `guidance-md.md` (from issues skill)

Merge checklists and rationalizations tables from both skills.

## Acceptance criteria

- [ ] `tools/ai/claude/config/skills/plan/SKILL.md` exists with frontmatter (name, description)
- [ ] All 7 steps documented
- [ ] Step 3 calls `plan-start`, writes PRD.md + COMMIT_HINT.md
- [ ] Step 7 calls `plan-end` after user permission
- [ ] All 4 reference files present in `plan/references/`
- [ ] Merged checklist covers both PRD and Issues checkpoints
- [ ] Merged rationalizations table covers traps from both skills
