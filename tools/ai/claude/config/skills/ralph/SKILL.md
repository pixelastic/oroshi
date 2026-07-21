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

If a dedicated skill for your language exists, load it (`zsh-writer`, `js-writer`, `python-writer`, etc)
It defines how to run tests for that language.

If you have any `## Behavioral Tests` from the issue:
- Read [behavioral-tests.md](../tdd/references/behavioral-tests.md)
- Write tests in `__tests__` folder, next to the file being tested.

If you have any `## Scaffolding Tests` from the issue:
- Read [scaffolding-tests.md](../tdd/references/scaffolding-tests.md)
- Write tests in `plans/<slug>/scaffold/<issue-filename>.bats`

**Run tests. If they passes immediately: tests are wrong. Rewrite them.**

**Do not write any production code in this step.**

---

## Step 3 — IMPLEMENT

**Goal:** Make the tests pass with minimal code, then verify the full suite.

**Exit criterion:** Linter clean, all tests green.

1. Language skill already loaded in Step 2 — follow its style and conventions.
2. Edit files inside the current git root (`git-directory-root`)
3. Write the simplest code that makes the tests pass. No more.
4. Refactor: remove duplication, improve names, extract helpers. Don't add behavior.
5. Lint all modified files with `git-file-lint` and fix any issues.
6. Run tests for all modified files using `git-file-test`. All tests must pass.

---

## Step 4 — REVIEW

**Goal:** Get external feedback and categorize it.

**Exit criterion:** Findings categorized and displayed.

1. Run the **/review skill** using the **Skill tool** (not Bash tool)
    - Skill name: `review`
    - Args: `ref:dirty` and `spec:<issue_path>`
    - DO NOT use the Bash tool to run `review`
2. Categorize ALL findings (from both Standards and Spec) into two buckets:
   - **skipped** — out of scope or not relevant, with one-line reason per item
   - **fixable** — actionable and in scope
3. Display the two buckets as a summary
4. Move to the next step (FIX). Do not stop or wait for user input.

---

## Step 5 — FIX

**Goal:** Apply fixable feedback, verify nothing broke.

**Exit criterion:** All fixable items addressed, linter clean, tests green.

1. Consume the **fixable** bucket, fix every item.
2. Lint all modified files with `git-file-lint` and fix any issues.
3. Run tests for all modified files using `git-file-test`. All tests must pass.

---

## Step 6 — UPDATE PLAN ARTIFACTS

**Goal:** Persist session state for future sessions.

**Exit criterion:** `state.json`, `GUIDANCE.md` (optional), and `review-log.md` (optional) updated.

All paths of the following files are from `ralph-start` output.

1. **Update `state.json`**: find the issue
   entry by `id`, set `done: true`, add `recap` — a short one-sentence summary
   of what was done.

2. **Append to `GUIDANCE.md`** under `## Discoveries`:
   ```
   ### Issue XX — <title>
   - <non-trivial finding>
   ```
   Skip if there are no non-trivial findings.

3. If the **skipped** bucket is non-empty, create or append to `review-log.md`.
   Load [review-log.md](references/review-log.md) for the review-log format.

---

## Step 7 — WRITE COMMIT HINT

**Goal:** Leave a hint so the commit message author understands what was built.

**Exit criterion:** `COMMIT_HINT.md` written.

Write `COMMIT_HINT.md` (path from `ralph-start` output).

Load [commit-hint.md](references/commit-hint.md) for the format and rules.

---

## Step 8 — STOP

**Goal:** Hand off to user.

**Exit criterion:** `ralph-end` called, session recap displayed.

- Run `ralph-end $ARGUMENTS` first

Print:
```
Issue XX/total

**Problem solved:** {short description}

**What changed:** {bullet point list of changes}

**How to test:** (optional) {only if no automated tests}

**Discoveries:** {any non-trivial findings}
```


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
| "I mentioned an issue COMMIT_HINT.md to be specific" | Issue are ephemeral and internal. Describe what was built, not which issue was closed. |

## Checklist

- [ ] Ran `ralph-start`, parsed output, handled finished/deadlocked
- [ ] Read guidance file and issue spec
- [ ] Language skill loaded before writing tests
- [ ] Declared test strategy before writing any test
- [ ] Behavioral tests written to `__tests__/`
- [ ] Scaffolding tests written to plans/<slug>/scaffold/, not __tests__/
- [ ] RED: wrote failing tests, ran them, confirmed they fail
- [ ] IMPLEMENT: minimal code, all behaviors covered
- [ ] Code written following the language skill's standards
- [ ] Linter clean on modified files
- [ ] Tests green for modified files
REVIEW:
- [ ] Ran `/review` via Skill tool and received output
- [ ] Pass `ref:dirty` and `spec:<path>` to the review skill
- [ ] Findings categorized into **fixable** and **skipped** buckets
- [ ] Summary of both buckets displayed
FIX:
- [ ] All **fixable** items fixed
- [ ] Linter + tests green for modified files after fixes
- [ ] state.json updated with `done: true` + `recap`
- [ ] GUIDANCE.md discoveries appended (or skipped if none)
- [ ] review-log.md updated if **skipped** bucket is non-empty
- [ ] COMMIT_HINT.md describes outcomes, not issue numbers or plan status
- [ ] **Stopped — waiting for user to commit**
