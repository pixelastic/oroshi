## TLDR

Split Ralph Step 4 ("Review & Fix") into REVIEW (categorize) and FIX (apply), renumber downstream steps and checklist.

## What to build

In `tools/ai/claude/config/skills/ralph/SKILL.md`:

**Step 4 — REVIEW** (rewrite existing Step 4):
- Run `/review` via Skill tool with `ref:dirty` and `spec:<issue_path>`
- Categorize ALL findings (from both Standards and Spec) into two named buckets:
  - **fixable** — actionable and in scope
  - **skipped** — out of scope or not relevant, with one-line reason per item
- Display the two buckets as a summary before moving on
- Exit criterion: findings categorized and displayed

**Step 5 — FIX** (new step):
- Consume the **fixable** bucket, fix every item
- Lint all modified files with `git-file-lint`
- Run tests with `git-file-test`
- Exit criterion: all fixable items addressed, linter clean, tests green

**Step 6 — UPDATE PLAN ARTIFACTS** (was Step 5):
- Renumber
- Change "If review had skipped items" to reference the **skipped** bucket by name

**Step 7 — WRITE COMMIT HINT** (was Step 6): renumber only

**Step 8 — STOP** (was Step 7): renumber only

**Checklist**: split current Step 4 items into REVIEW and FIX sections, renumber remaining items.

No changes to the Common Rationalizations table.
No "do not stop" instruction in REVIEW — lean first.
No changes to the `/review` skill.

## Acceptance criteria

- [ ] Step 4 is REVIEW only — no fix logic
- [ ] Step 4 defines **fixable** and **skipped** buckets
- [ ] Step 4 instructs agent to display categorized summary
- [ ] Step 5 (FIX) exists and consumes the **fixable** bucket
- [ ] Step 6 (UPDATE PLAN ARTIFACTS) references the **skipped** bucket by name
- [ ] Steps 7-8 renumbered correctly
- [ ] Checklist split into REVIEW and FIX sections
- [ ] Checklist items renumbered to match new step numbers
- [ ] No "belt and suspenders" instruction added
- [ ] No new Common Rationalizations entry added
- [ ] Review skill untouched
