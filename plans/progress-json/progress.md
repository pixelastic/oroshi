## Session 2026-05-28 — 01: plans-directory

- Completed: renamed `ralph-directory` → `plans-directory` (output now `plans/$slug/`); updated `git-worktree-is-ralph` to check `plans/<slug>/state.json`; updated bats tests for both; updated `ralph-progress` call site and its deduction test
- Tests added: `plans-directory.bats` (4 tests); updated `git-worktree-is-ralph.bats` (2 tests); updated `ralph-progress.bats` (1 test)
- Discovered: `ralph-progress` calls `ralph-directory` → needed a minimal fixup to `plans-directory`; also needed `state.json` in its worktree deduction test
- Fixed: `ralph-progress` call site updated to `plans-directory`; guards + comment added to `plans-directory` after review
- Skipped feedback: spec agent flagged `ralph-progress` still reads `issues.json` (not `state.json`) — out of scope, covered by issue 06
- Next: issue 03 (ralph-json: rename `.ralph-state.json` → `ralph.json`) — unblocked, unblocks 05 and 06
