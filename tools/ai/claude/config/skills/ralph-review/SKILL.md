---
name: ralph-review
description: Use when user says "ralph-review <dir>", or after the last ralph issue is done. Reviews every change of a ralph plan against its PRD, fixes actionable feedback, then stops for the user to commit. Argument is the directory containing state.json and PRD.md.
argument-hint: [directory]
---

# Ralph Review

## Overview

One review of the whole plan, fixed, stopped. Do not commit. Runs once after the
last `ralph` issue, over the full range of the plan.

Working directory: **`$ARGUMENTS`** (the plan directory). If `$ARGUMENTS` is
empty, `"this"`, `"."`, or `"here"` → use current working directory.

## Core Workflow

### Step 1 — SETUP

**Goal:** Find the range to review and the spec to review against.

**Exit criterion:** `ref` and `spec` known.

Run `ralph-review-start <dir>` and parse the JSON output. Keep `ref` and `spec`.

### Step 2 — REVIEW

**Goal:** Get external feedback and categorize it.

**Exit criterion:** Findings categorized and displayed.

1. Run the **/review skill** using the **Skill tool** (not Bash tool)
   - Skill name: `review`
   - Args: `ref:<ref> spec:<spec>`
   - DO NOT use the Bash tool to run `review`
   - DO NOT stop when the review skill completes
2. Categorize ALL findings (from both Code Review and Spec Review) into two
   buckets:
   - **skipped** — out of scope or not relevant, with one-line reason per item
   - **fixable** — actionable and in scope
3. Display the two buckets as a summary.
4. **Immediately** move to Step 3 in the same response. Do not stop, do not wait
   for user input, do not end your turn.

### Step 3 — FIX

**Goal:** Apply fixable feedback, verify nothing broke.

**Exit criterion:** All fixable items addressed, linter clean, tests green.

1. Consume the **fixable** bucket, fix every item.
2. Refactor: apply the `/{lang}-writer` skill's style patterns. Don't add
   behavior.
3. Lint all modified files with `git-file-lint`. Fix **every** violation,
   including pre-existing ones.
4. Run tests for all modified files using `git-file-test`. Fix **every** failing
   test, including pre-existing ones.

### Step 4 — STOP

**Goal:** End the session with the user in control.

**Exit criterion:** Recap displayed, nothing committed.

Print both buckets and what the fixes changed. Do not commit. Do not write
`review-log.md`. Do not touch `state.json`, `GUIDANCE.md` or `COMMIT_HINT.md`.
Wait for the user.

## Common Rationalizations

| Rationalization                                            | Reality                                                                                             |
| ---------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| "I should run `review` via the Bash tool"                  | Use the `/review` skill instead, Bash will go to the background and we need to wait for the review. |
| "I should present review findings and wait for user input" | Steps 2→3 are continuous. Categorize, display, fix. No pause between REVIEW and FIX.                |
| "Fixes are small, no need to refactor"                     | Post-fix code is still code. Refactor every time you touch code.                                    |
| "I should log skipped items in review-log.md"              | This skill writes no plan artifacts. Display the skipped bucket only.                               |
| "I should commit so the work is saved"                     | Do not commit. That's the user's job.                                                               |

## Checklist

- [ ] Ran `ralph-review-start`, kept `ref` and `spec`
- [ ] Ran `/review` via Skill tool with `ref:<ref> spec:<spec>`
- [ ] Findings categorized into **fixable** and **skipped** buckets
- [ ] Summary of both buckets displayed
- [ ] All **fixable** items fixed
- [ ] Refactored after fixes: applied `/{lang}-writer` style patterns
- [ ] Linter + tests green for modified files
- [ ] No commit, no `review-log.md`, `state.json`, `GUIDANCE.md` or
      `COMMIT_HINT.md` change
- [ ] **Stopped — waiting for user to commit**
