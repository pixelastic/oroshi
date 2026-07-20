## Problem Statement

Ralph's Step 4 ("Review & Fix") calls the `/review` skill, which ends by displaying two formatted reports. The agent treats this output as a natural stopping point and presents findings to the user instead of immediately proceeding to fix actionable items. The step is called "Review & Fix" but in practice it only Reviews.

The root cause: `/review` ends with "present the reports" — which looks like a conversation endpoint. Ralph Step 4 says "for each feedback item, fix it", but this instruction isn't forceful enough to override the implicit pause created by the review output.

## Solution

Split Ralph Step 4 into two distinct steps with a clear boundary:

- **Step 4 — REVIEW**: run the review, categorize findings into two named buckets (**fixable** and **skipped**), display the categorized summary.
- **Step 5 — FIX**: consume the **fixable** bucket, fix every item, lint, test.

The step boundary acts as a natural continuation signal — the agent completes REVIEW and sees FIX as the next step to execute, rather than treating the review output as a stopping point.

The `/review` skill itself is NOT modified — it's also used standalone where stopping after display is correct.

## User Stories

1. As Ralph's author, I want the agent to reliably continue from review to fixing, so that "Review & Fix" actually reviews AND fixes.
2. As Ralph's author, I want review findings categorized into named buckets (fixable/skipped), so that downstream steps can reference them by name.
3. As Ralph's author, I want the REVIEW step to display a summary of both buckets before moving on, so that I can see what the agent plans to fix vs skip.
4. As Ralph's author, I want the UPDATE PLAN ARTIFACTS step to reference the "skipped" bucket by name, so that the vocabulary is consistent across steps.
5. As Ralph's author, I want the checklist split to mirror the step split, so that each step's deliverables are independently verifiable.

## Implementation Decisions

### Single file change

Only `tools/ai/claude/config/skills/ralph/SKILL.md` is modified. The review skill is untouched.

### Two named buckets

The REVIEW step introduces two buckets for categorizing ALL review findings regardless of source (Standards or Spec):

- **fixable** — actionable and in scope
- **skipped** — out of scope or not relevant (with one-line reason per skip)

These bucket names are then referenced by downstream steps.

### No "belt and suspenders"

No explicit "do not stop" or "proceed to next step" instruction in the REVIEW step. The structural split should be sufficient. If the agent still stops after review, we add the explicit instruction later.

### No new rationalization entry

No addition to the Common Rationalizations table. Same reasoning — lean first, add if needed.

### Discoveries remain session-wide

Non-trivial discoveries written to GUIDANCE.md are a session-wide concern, not a review bucket. They can surface during RED, IMPLEMENT, or REVIEW. They stay in UPDATE PLAN ARTIFACTS, unconnected to the fixable/skipped categorization.

### Renumbering

Steps 5-7 become 6-8. No external references to Ralph step numbers exist — renumbering is safe.

### Vocabulary in UPDATE PLAN ARTIFACTS

The current "If review had skipped items" wording is updated to reference the **skipped** bucket by name, tying back to the REVIEW step's vocabulary.

### Checklist split

Current Step 4 checklist items are split into REVIEW and FIX sections:

- REVIEW: ran `/review`, passed correct args, findings categorized into fixable and skipped
- FIX: all fixable items addressed, linter + tests green

## Testing Decisions

No tests. This is a markdown skill definition, not executable code.

## Out of Scope

- Modifying the `/review` skill — it's correct as-is for standalone use.
- Adding "belt and suspenders" (explicit "proceed" instruction) — reserved for later if the split alone doesn't work.
- Adding a new Common Rationalizations entry — reserved for later.
- Changing how discoveries are handled in UPDATE PLAN ARTIFACTS.

## Further Notes

The edit must be made in the worktree path (`tools/ai/claude/config/skills/ralph/SKILL.md`), not via the `~/.claude/skills/` symlink. The change will be merged into main later.
