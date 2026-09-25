# Write PRD

Crystallize the plan into a PRD and persist it in a dedicated worktree.

1. Create worktree — `plan-start` sets up paths
2. Write PRD — follow the template

---

## Create worktree

Run `plan-start <branchName>` and parse the JSON output:
- `branch` — current branch name
- `planDir` — directory for all plan artifacts

## Write PRD

Write `PRD.md` to `<planDir>/PRD.md`, following [the PRD template](./templates/PRD.template.md).

## Checklist

- [ ] `plan-start <branchName>` called, JSON output parsed
- [ ] PRD.md written in english to `<planDir>/PRD.md`, follows template
