## PRD

plans/progress-json/PRD.md

## What to build

Update `prd-end` to output `plans/<slug>/PRD.md` instead of `ralph/<slug>/PRD.md`.

Single line change: the `jo` call at the end uses `plans` instead of `ralph` in the path.

No tests exist for prd-end (it creates worktrees, hard to test in isolation). Verify manually.

## Acceptance criteria

- [ ] `prd-end` outputs JSON with `prdPath` containing `plans/<slug>/PRD.md`
- [ ] The `jo` command builds the correct absolute path

## Blocked by

None — can start immediately
