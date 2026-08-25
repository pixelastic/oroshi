# Write PRD

Crystallize the plan into a PRD and persist it in a dedicated worktree.

1. Create worktree — `plan-start` sets up paths
2. Enter worktree — `cd` into `worktreePath`
3. Write PRD — follow the template

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

## Checklist

- [ ] `plan-start <branchName>` called, JSON output parsed
- [ ] `cd` into `worktreePath`
- [ ] PRD.md written in english to `<planDir>/PRD.md`, follows template
