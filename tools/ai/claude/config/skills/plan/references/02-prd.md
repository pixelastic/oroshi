# Write PRD

Crystallize the plan into a PRD and persist it in a dedicated worktree.

1. Create worktree — `plan-start` sets up paths
2. Enter worktree — `cd` into `worktreePath`
3. Write PRD — follow the template
4. Write `COMMIT_HINT.md` — describe goal and scope

---

## Create worktree

Run `plan-start <branchName>` and parse the JSON output:
- `worktreePath` — git worktree root
- `branch` — current branch name
- `planDir` — directory for all plan artifacts

## Enter worktree

`cd` into `worktreePath`.

## Write PRD

Write `PRD.md` to `<planDir>/PRD.md`, following [the PRD template](./templates/PRD.template.md).

## Write COMMIT_HINT

Write `COMMIT_HINT.md` to `<planDir>/COMMIT_HINT.md`.
Load the **commit hint** reference from the `/ralph` skill for format and rules.
Derive Goal from the PRD's Problem Statement.
Suggested type is `plan(<slug>)` where slug is the plan directory name.

## Checklist

- [ ] `plan-start <branchName>` called, JSON output parsed
- [ ] `cd` into `worktreePath`
- [ ] PRD.md written in english to `<planDir>/PRD.md`, follows template
- [ ] `COMMIT_HINT.md` written with `plan(<slug>)` type
