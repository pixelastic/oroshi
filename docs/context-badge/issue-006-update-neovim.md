## PRD

`docs/context-badge/PRD.md`

## What to build

Update NeoVim and remove the deleted function.

**NeoVim `statusline.lua`**: replace the `project-by-path` shell call with `context-project`.

**Delete `project-by-path`**: once all callers have been migrated (prompt in issue-004, FZF in issue-005, NeoVim here), remove the `project-by-path` autoload function.

## Acceptance criteria

- [ ] NeoVim statusline calls `context-project` (not `project-by-path`)
- [ ] `project-by-path` autoload function deleted
- [ ] No remaining references to `project-by-path` anywhere in the codebase

## Blocked by

- issue-001 (`context-project` must exist)
- issue-004 (prompt must be migrated before `project-by-path` can be deleted)
- issue-005 (FZF must be migrated before `project-by-path` can be deleted)
