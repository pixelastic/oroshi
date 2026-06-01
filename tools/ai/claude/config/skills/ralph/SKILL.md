---
name: ralph
description: Use when user says "ralph <dir>" or "ralph this". Implements the highest-priority issue from state.json in the given directory using TDD, updates docs, runs review in a subagent, fixes actionable feedback, then stops for user to commit. Argument is the directory containing state.json and GUIDANCE.md.
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

**Goal:** Select the next issue and load context.

**Exit criterion:** Issue selected, guidance loaded, ready to implement.

Run `ralph-start $ARGUMENTS` and parse the JSON output:

- `status: "finished"` → display "All issues complete." and stop.
- `status: "deadlocked"` → display the `message` field and stop.
- `status: "ready"` → continue.

Read the file at the `guidance` path — accumulated knowledge from prior sessions.

Read the file at the `issue` path — the spec for this session.

Display a one-line recap of the selected issue.

---

## Step 2 — RED

**Goal:** Write tests that fail — either because the feature doesn't exist yet,
or because they demonstrate a bug.

**Exit criterion:** Test runs and fails.

Read the `## Permanent Tests` and `## Scaffolding Tests` sections from the issue.
Permanent tests go to `__tests__/` as usual
Scaffolding tests go to `plans/<slug>/scaffold/<issue-filename>.bats`

Write the tests that cover the acceptance criteria of the issue — at least one
per criterion. Run them. Read the failure output.

**If tests passes immediately: tests are wrong. Rewrite them.**

**Do not write any production code in this step.**

---

## Step 3 — IMPLEMENT

**Goal:** Make the tests pass with minimal code, then verify the full suite.

**Exit criterion:** Linter clean, all tests green.

1. If a dedicated skill for your language exists, load it (`zsh-writer`, `js-writer`, etc)
2. Write the simplest code that makes the tests pass. No more.
3. Refactor: remove duplication, improve names, extract helpers. Don't add behavior.
3. Lint all modified files with `git-file-lint` and fix any issues.
4. Run tests for all modified files using `git-file-test`. All tests must pass.

---

## Step 4 — REVIEW & FIX

**Goal:** Get external feedback, apply it, verify nothing broke.

**Exit criterion:** All actionable feedback addressed, linter clean, tests green.

1. Run the **/review skill** using the **Skill tool** (skill name: `review`, no args):
    - DO NOT use the Bash tool to run `review`
    - Wait for the skill to finish before proceeding.
2. For each feedback item:
   - **Actionable and in scope** → fix it
   - **Out of scope or not relevant** → note it, will go in review-log.md (path from `ralph-start` output)
3. Lint all modified files with `git-file-lint` and fix any issues.
4. Run tests for all modified files using `git-file-test`. All tests must pass.

---

## Step 5 — DOCUMENT

**Goal:** Leave full context for the next session.

**Exit criterion:** `state.json`, `GUIDANCE.md` (optional) and `review-log.md` (optional) updated.

1. **Update `state.json`** (path from `ralph-start` output): find the issue
   entry by `id`, set `done: true`, add `recap` — a short one-sentence summary
   of what was done.

2. **Append to `GUIDANCE.md`** (path from `ralph-start` output) under `## Discoveries`:
   ```
   ### Issue XX — <title>
   - <non-trivial finding>
   ```
   Skip this step if there are no non-trivial findings.

3. **If review had skipped items**, create or append at the end of `review-log.md` (path from `ralph-start` output):
   ```
   ## Issue XX — <title>
   ### <feedback item>
   ```code block of the flagged code```
   **Problem:** <what the reviewer flagged>
   **Reason skipped:** <why it was dismissed>
   ```

---

## Step 6 — STOP

**Goal:** Hand off to user.

**Exit criterion:** `ralph-end` called, session recap displayed.

- Run `ralph-end $ARGUMENTS` first

- Print the issue id, recap, and any discoveries logged.

**Stop here. Do not commit. Do not start the next issue. Wait for the user.**

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I don't need a specific skill, I know that language" | You don't know my style. Follow the standards of the skill. |
| "I'll write the test after to go faster" | Tests-after prove nothing. Delete the code. Start with RED. |
| "I'll do one more issue while I'm at it" | One issue. Full stop. |
| "Review feedback is minor, not worth it" | Minor feedback ignored = minor bugs shipped. Fix it. |
| "I don't need to read the guidance and issue files, I can start implementing" | You can't. Read both — guidance has prior discoveries; the issue has the acceptance criteria. |
| "I should commit so the review has something to diff" | Do not commit. That's the user's job. |
| "I should run `review` via the Bash tool" | Use the `/review` skill instead, Bash will go to the background and we need to wait for the review. |

## Checklist

- [ ] Ran `ralph-start`, parsed output, handled finished/deadlocked
- [ ] Read guidance file and issue spec
- [ ] Declared test strategy before writing any test
- [ ] Scaffolding tests written to plans/<slug>/scaffold/, not __tests__/
- [ ] RED: wrote failing tests, ran them, confirmed they fail
- [ ] IMPLEMENT: minimal code, all behaviors covered
- [ ] Code written following the standards of the language skill (`zsh-writer`, `js-writer`, etc)
- [ ] Linter clean on modified files
- [ ] Tests green for modified files
- [ ] Ran `/review` via Skill tool and received output
- [ ] Actionable feedback fixed or explicitly dismissed
- [ ] Linter + tests green for modified files after review fixes
- [ ] state.json updated with `done: true` + `recap`
- [ ] GUIDANCE.md discoveries appended (or skipped if none)
- [ ] review-log.md updated if skipped feedback exists
- [ ] **Stopped — waiting for user to commit**
