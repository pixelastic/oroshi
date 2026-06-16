## TLDR

Improve ralph's COMMIT_HINT authoring and restructure the DOCUMENT phase into three sequential steps, plus register `plan` as a valid commit type in both commit prompts.

## What to build

### ralph/references/commit-hint.md (new file)

A reference file loaded by ralph at Step 6 (and by the prd skill at its COMMIT_HINT step). It contains:
- The COMMIT_HINT.md template with four sections: Goal, Done, Key files, Suggested type(scope)
- "Done" framed as outcomes: what was built, what behavior changed, what bug was fixed — never issue status
- An explicit prohibition: no issue numbers, no plan-internal references; the commit message must stand alone
- Rationalizations specific to this step (e.g. "I mentioned issue 03 to be specific" → issue numbers are plan-internal and untraceable)

### ralph/references/review-log.md (new file)

A reference file loaded by ralph at Step 7. Contains the review-log.md format extracted from the current SKILL.md Step 5.4, including the markdown code block structure for logging skipped feedback items.

### ralph/SKILL.md — step restructure

The current Step 5 (DOCUMENT) has four sub-tasks conflated into one step. Split into three steps:

- **Step 5 — UPDATE PLAN ARTIFACTS**: update state.json (`done: true` + `recap`) and append to GUIDANCE.md (discoveries, if any) and update review-log.md (if skipped items exist). All three are plan artifacts committed to the repo. Reference `review-log.md` format via `references/review-log.md`.
- **Step 6 — WRITE COMMIT HINT**: write COMMIT_HINT.md only. Load `references/commit-hint.md` for the format and rules.
- **Step 7 — LOG SKIPPED FEEDBACK**: move review-log update here.
- **Step 8 — STOP**: the current Step 6 content unchanged.

Wait — review-log is a plan artifact (Step 5) but also needs its own format reference (Step 7). Reconcile: review-log.md update belongs in Step 5 alongside state.json and GUIDANCE.md, since all three are committed repo files. Step 7 becomes the old Step 6 (STOP becomes Step 8). The reference file is still loaded in Step 5 when the model needs to write the review-log format.

Revised structure:
- Step 5 — UPDATE PLAN ARTIFACTS (state.json + GUIDANCE.md + review-log.md)
- Step 6 — WRITE COMMIT HINT (COMMIT_HINT.md, ephemeral)
- Step 7 — STOP

That's 7 steps total, not 8.

Add to Common Rationalizations:
> "I mentioned issue 03 in COMMIT_HINT.md to be specific" → Issue numbers are plan-internal. Once the plan is deleted, they're untraceable. Describe what was built, not which issue was closed.

Add to Checklist (under DOCUMENT items):
> - [ ] COMMIT_HINT.md describes outcomes, not issue numbers or plan status

### prompt-with-hint.md + prompt-without-hint.md

Add `plan` to the types list in both files with a one-line description: `plan` — creation or deletion of a ralph plan directory. Both files must list identical types.

## Behavioral Tests

None — all changes are configuration artifacts (skill files and prompt files). The files themselves are the artifact.

## Scaffolding Tests

None.

## Acceptance criteria

- [ ] `ralph/references/commit-hint.md` exists with Goal / Done / Key files / Suggested type(scope) sections
- [ ] "Done" section in commit-hint.md is framed as outcomes, not issue status
- [ ] commit-hint.md explicitly prohibits issue numbers and plan-internal references
- [ ] commit-hint.md includes a rationalization entry for the issue-number antipattern
- [ ] `ralph/references/review-log.md` exists with the review-log format
- [ ] ralph SKILL.md Step 5 covers state.json + GUIDANCE.md + review-log.md and references review-log.md format
- [ ] ralph SKILL.md Step 6 covers COMMIT_HINT.md only and references commit-hint.md
- [ ] ralph SKILL.md Step 7 is STOP (the old Step 6 content)
- [ ] ralph SKILL.md Common Rationalizations includes the issue-number antipattern
- [ ] ralph SKILL.md Checklist includes item: COMMIT_HINT.md describes outcomes, not issue numbers
- [ ] `plan` type added to prompt-with-hint.md types list with description
- [ ] `plan` type added to prompt-without-hint.md types list with description
- [ ] Both prompts list identical types
