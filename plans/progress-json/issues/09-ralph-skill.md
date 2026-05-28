## PRD

plans/progress-json/PRD.md

## What to build

Rewrite the `ralph` skill (SKILL.md) to use the new workflow:

**Step 1 — SETUP:** Run `ralph-start <dir>` and parse the JSON output. If `status: "done"`, display message and stop. Read `paths.guidance` for accumulated knowledge. Read `paths.spec` for the issue to implement.

**Step 2 — RED/IMPLEMENT/REVIEW:** Same TDD flow as today. No changes to steps 3-5 logic.

**Step 6 — DOCUMENT:** Replace the old progress.md append with:
1. Update `state.json`: set the issue's `done: true`, add `recap` key with a short summary
2. Append to `GUIDANCE.md` under `## Discoveries` → `### Issue XX — title` with any non-trivial findings
3. If review had skipped items: create/append `review-log.md` with the skip entries (H2 per issue, H3 per skip with code block, problem, reason)

**Step 7 — STOP:** Run `ralph-end <dir>`. Display the recap.

Update the checklist, common rationalizations, and description to match.

## Acceptance criteria

- [ ] Step 1 uses `ralph-start` output, handles `status: "done"`
- [ ] Step 6 updates state.json with `done: true` + `recap`
- [ ] Step 6 appends discoveries to GUIDANCE.md under the correct H3 heading
- [ ] Step 6 creates/appends review-log.md for skipped review feedback
- [ ] Step 7 calls `ralph-end`
- [ ] No reference to progress.md or issues.json anywhere in the skill
- [ ] Checklist reflects new file names

## Blocked by

- 04 (needs `ralph-start`)
- 05 (needs updated `ralph-end`)
- 08 (needs to-issues skill for consistent file format references)
