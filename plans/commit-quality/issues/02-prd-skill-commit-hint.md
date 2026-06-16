## TLDR

Add a COMMIT_HINT.md authoring step to the prd skill so that plan-creation commits travel through the commitWithHint path and get a `plan(<slug>)` type.

## What to build

### prd/SKILL.md — new Step 4

Insert a new step between the current Step 3 (Write the PRD.md) and Step 4 (Stop):

**Step 4 — Write COMMIT_HINT.md**

Write COMMIT_HINT.md in the plan directory (same directory as PRD.md). Load `../ralph/references/commit-hint.md` for the format and rules. The Goal section should be derived from the Problem Statement of the PRD just written. Suggested type is `plan(<slug>)` where slug is the plan directory name.

The current Step 4 becomes Step 5.

### prd/SKILL.md — checklist

Add a checklist item:
> - [ ] COMMIT_HINT.md written in plan directory with `plan(<slug>)` type

## Behavioral Tests

None — configuration artifact.

## Scaffolding Tests

None.

## Acceptance criteria

- [ ] prd SKILL.md has a Step 4 titled "Write COMMIT_HINT.md"
- [ ] Step 4 instructs loading `../ralph/references/commit-hint.md`
- [ ] Step 4 instructs deriving Goal from the PRD's Problem Statement
- [ ] Step 4 specifies `plan(<slug>)` as the suggested type
- [ ] The old Step 4 (Stop / ask user) is renumbered to Step 5
- [ ] Checklist includes item for COMMIT_HINT.md written with plan type
