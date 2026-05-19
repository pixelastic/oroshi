---
name: ralph
description: Use when user says "ralph <dir>" or "ralph this". Implements the highest-priority issue from prd.json in the given directory using TDD, updates docs, runs review in a subagent, fixes actionable feedback, then stops for user to commit. Argument is the directory containing prd.json and progress.md.
argument-hint: [directory]
effort: high
---

# Ralph

## Overview

One issue, TDD, documented, reviewed, fixed, stopped. Do not commit. Do not continue to the next issue.

Working directory: **`$ARGUMENTS`**
If `$ARGUMENTS` is empty, `"this"`, `"."`, or `"here"` → use current working directory.

---

## Step 1 — SETUP

**Goal:** Load current PRD state and session history.

**Exit criterion:** You've read prd.json, progress.md, and know which issues are open.

Read:
- `$ARGUMENTS/prd.json` — issues, statuses, metadata
- `$ARGUMENTS/progress.md` — session history

---

## Step 2 — PICK

**Goal:** Select exactly one issue to implement this session.

**Exit criterion:** One issue selected, detail file read.

Evaluate all open issues. You decide priority — not necessarily the first listed. Weight: blockers, dependencies, impact, complexity.

Glob for `$ARGUMENTS/issue-*.md`. Read the detail file for your chosen issue.

**Pick one. Touch nothing else.**

---

## Step 3 — RED

**Goal:** Write tests that fail — either because the feature doesn't exist yet, or because they demonstrate a bug.

**Exit criterion:** Test runs and fails.

Write the tests that cover the acceptance criteria of the issue — at least one per criterion. Run them. Read the failure output.

**If tests passes immediately: tests are wrong. Rewrite them.**

**Do not write any production code in this step.**

---

## Step 4 — IMPLEMENT

**Goal:** Make the tests pass with minimal code, then verify the full suite.

**Exit criterion:** Linter clean, all tests green.

1. If a dedicated skill for your language exists, load it (`zsh-writer`, `js-writer`, etc)
2. Write the simplest code that makes the tests pass. No more.
3. Refactor: remove duplication, improve names, extract helpers. Don't add behavior.
4. Run the linter on all modified files. Fix any errors.
5. Run tests for all modified files. All tests must pass.

---

## Step 5 — REVIEW & FIX

**Goal:** Get external feedback, apply it, verify nothing broke.

**Exit criterion:** All actionable feedback addressed, linter clean, tests green.

1. Spawn a subagent (via Agent tool). The subagent runs the `review` CLI tool on the current changes. Capture the output.
2. For each feedback item:
   - **Actionable and in scope** → fix it
   - **Out of scope or not relevant** → note it in progress.md under `Skipped feedback:`
3. Run the linter on all modified files. Fix any errors.
4. Run tests for all modified files. All tests must pass.

---

## Step 6 — DOCUMENT

**Goal:** Leave full context for the next session.

**Exit criterion:** progress.md and prd.json both updated.

Append to `$ARGUMENTS/progress.md`:

```
## Session YYYY-MM-DD — <issue-id>: <title>
- Completed: <what was done>
- Tests added: <list>
- Discovered: <unexpected issues found, or "none">
- Fixed: <unplanned fixes made, or "none">
- Skipped feedback: <review items not applied, or "none">
- Next: <recommended next issue or action>
```

Update `$ARGUMENTS/prd.json`: mark issue as complete, update any relevant status fields.

---

## Step 7 — STOP

**Goal:** Hand off to user.

**Exit criterion:** `ralph-end` called, session recap displayed.

- Run `ralph-end $ARGUMENTS` first
- Print the session entry that was written to progress.md

**Stop here. Do not commit. Do not start the next issue. Wait for the user.**

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I don't need a specific skill, I know that language" | You don't know my style. Follow the standards of the skill. |
| "I'll write the test after to go faster" | Tests-after prove nothing. Delete the code. Start with RED. |
| "I'll do one more issue while I'm at it" | One issue. Full stop. |
| "Review feedback is minor, not worth it" | Minor feedback ignored = minor bugs shipped. Fix it. |
| "I can infer priority without reading the detail file" | You can't. Read the file. |
| "I should commit so the review has something to diff" | Do not commit. That's the user's job. |

## Checklist

- [ ] Read prd.json + progress.md
- [ ] Picked one issue, read its detail file
- [ ] RED: wrote failing tests, ran them, confirmed they fail
- [ ] IMPLEMENT: minimal code, all behaviors covered
- [ ] Code written following the standards of the language skill (`zsh-writer`, `js-writer`, etc)
- [ ] Linter clean on modified files
- [ ] Tests green for modified files
- [ ] review subagent ran, output captured
- [ ] Actionable feedback fixed or explicitly dismissed
- [ ] Linter + tests green for modified files after review fixes
- [ ] progress.md updated with session entry
- [ ] prd.json updated
- [ ] **Stopped — waiting for user to commit**
