## PRD

[ralph --max loop](./PRD.md)

## What to build

Add `--max N` flag to the `ralph` script that runs autonomously for up to N iterations. Without the flag, `ralph` behaves exactly as before.

In loop mode, each iteration:
1. Starts Claude interactively using job control (`setopt MONITOR`), capturing its PID, then brings it to the foreground with `fg %claude` — the TUI is fully visible and the user can type at any time.
2. A background sentinel watcher polls `<dir>/.ralph-done` every 5 seconds. When found, it deletes it and sends SIGTERM to Claude.
3. When Claude exits (killed by watcher, or Ctrl+C), all background jobs are killed via their process groups.
4. If Claude exited with code 130 (Ctrl+C / SIGINT), the loop stops cleanly with no commit.
5. If `git status` shows changes: `git add --all`, generate message via `git-commit-message`, commit. If nothing staged, skip silently.
6. If `<dir>/.ralph-prd-done` exists: delete it and exit the loop with a message. Otherwise start the next iteration.

## Acceptance criteria

- [ ] `ralph <dir>` (no flag) behaves identically to before — single interactive Claude session, no loop
- [ ] `ralph --max 3 <dir>` runs exactly 3 iterations (stubbed `claude` that calls `ralph-end` and exits 0)
- [ ] Each iteration that produces changes results in one git commit
- [ ] Iterations that produce no changes do not create an empty commit
- [ ] When the stubbed `claude` exits with code 130, the loop stops and no commit is attempted
- [ ] When `<dir>/.ralph-prd-done` is present after a commit, the loop exits early (fewer than `--max` iterations)
- [ ] After each iteration's Claude exits, no background watcher or monitor processes remain
- [ ] All bats tests pass

## Blocked by

- [issue-0001](./issue-0001-ralph-end-script.md) — sentinel files must exist before the loop can respond to them
