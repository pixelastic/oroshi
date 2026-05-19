## Problem Statement

Running `ralph` on a PRD with multiple independent issues requires manual intervention between each issue: the user must wait for Claude to finish, commit the changes, kill the interactive session, and re-launch `ralph`. With five independent issues, this means five manual commit-and-relaunch cycles. The bottleneck is not the work itself but the handoff between issues.

## Solution

Add an `--max N` flag to `ralph` that runs autonomously for up to N iterations. After each completed issue, the loop auto-commits and re-launches Claude on the next issue — no human intervention needed. Claude still runs interactively (the TUI remains visible and the user can intervene or type at any time). The loop stops early if the PRD has no remaining open issues. An inactivity alert plays a sound if Claude has not touched the repo for 10 minutes, signalling that it may need the user's input.

## User Stories

1. As a developer with a multi-issue PRD, I want to run `ralph --max 5` so that Claude works through up to 5 issues autonomously without me re-launching it each time.
2. As a developer, I want to still see Claude's TUI output during automated runs so that I can monitor progress and intervene if needed.
3. As a developer, I want to be able to type into the Claude session at any time during an automated run so that I can guide or unblock Claude without aborting the loop.
4. As a developer, I want the loop to commit automatically after each completed issue so that each issue's work is a distinct commit.
5. As a developer, I want the commit message to be generated automatically from the diff so that I don't need to write commit messages manually.
6. As a developer, I want the loop to stop early if the PRD has no more open issues so that I don't waste iterations on an already-complete PRD.
7. As a developer, I want pressing Ctrl+C to stop the loop cleanly after the current Claude session exits, so that I can interrupt an automated run without leaving dangling processes.
8. As a developer who stepped away, I want a sound alert to play if Claude hasn't touched the repo in 10 minutes so that I know it may be waiting for my input.
9. As a developer, I want the sound alert to play only once per idle period and reset when activity resumes so that I'm not spammed with alerts.
10. As a developer, I want `ralph` without `--max` to behave exactly as before so that existing single-run workflows are not affected.

## Implementation Decisions

### Module 1 — Ralph skill: sentinel file

The ralph skill writes a sentinel file (`$ARGUMENTS/.ralph-done`) at the end of Step 7, after printing the session summary. This file signals to the outer loop that Claude has completed its work and the session can be closed. This is the only change to the skill.

The sentinel approach is used rather than `--print` (non-interactive) mode because the user needs to be able to type into the Claude session at any time during the run.

### Module 2 — Ralph script: loop core

The `--max N` flag triggers loop mode. Without this flag, `ralph` behaves exactly as before (backward compatible).

In loop mode:
- Job control is enabled (`setopt MONITOR`) so that Claude can be started in the background, its PID captured, and then brought to the foreground with `fg %claude` — giving it full terminal access while allowing background processes to run in parallel.
- A background sentinel watcher polls for `.ralph-done` every 5 seconds. When the sentinel is found, it deletes it and sends SIGTERM to the Claude process.
- `fg %claude` blocks the outer script until Claude exits (either killed by the watcher or by the user). If Claude exits with code 130 (SIGINT / Ctrl+C), the loop stops cleanly.
- After Claude exits, the watcher and monitor background jobs are killed via their process groups to ensure child processes (e.g. `inotifywait`) are also terminated.
- If `git status` shows changes, `git add --all` is run, a commit message is generated via `git-commit-message`, and the commit is created.
- If no changes are staged, the commit step is skipped silently.

### Module 3 — Ralph script: inactivity monitor

A second background job runs `inotifywait` on the git root with a 600-second (10-minute) timeout, watching for any file modification, creation, deletion, or move events (excluding `.git/`). If `inotifywait` exits with code 2 (timeout — no events in the window), and Claude is still running, and no alert has already been played in this idle period, `audio-play-oroshi ralph-timeout.mp3` is called once. If `inotifywait` exits with code 0 (activity detected), the idle flag resets and the loop continues.

The monitor runs in the same background job lifecycle as the sentinel watcher — it is started before `fg %claude` and killed (with its process group) after Claude exits.

### Module 4 — Ralph script: PRD completion check

After each commit, `jq` reads `$dir/prd.json` and counts issues whose `status` field is not `"complete"`. If the count is zero, the loop prints a message and breaks early. If `jq` fails (file missing or parse error), the count defaults to 1 (loop continues). This is the only place the loop inspects `prd.json` — the sentinel-based exit detection handles the per-iteration signal.

### No session continuity between iterations

Each iteration launches a fresh Claude session. The ralph skill re-reads `prd.json` and `progress.md` at Step 1, so all context is preserved in those files. There is no shared in-memory state between iterations.

### ADR: sentinel file over --print mode

Using a sentinel file to signal completion, rather than running Claude with `--print` (non-interactive mode), preserves full TUI interactivity. The trade-off is that the sentinel mechanism requires job control (`setopt MONITOR`) and explicit process group cleanup — complexity that `--print` would avoid. The interactive requirement was judged more important.

## Testing Decisions

Good tests verify observable side effects from a given invocation: files created or committed, sounds played, early exit triggered. Tests should not verify which internal functions were called or in what order.

**All four modules get bats tests.** Mock strategy:
- `claude` is stubbed as a shell function that writes `.ralph-done` to `$dir` and exits 0 (simulating a completed ralph session).
- `git-commit-message` is stubbed to output a fixed string.
- `audio-play-oroshi` is stubbed to write its argument to a capture file (no actual sound).
- `inotifywait` is stubbed to exit immediately with code 2 (simulating a timeout) for inactivity tests, or code 0 (simulating activity) for reset tests.
- `jq` is called on a real test `prd.json` fixture (no stub needed).

**Module 1 (skill sentinel):** tested implicitly — the loop core tests use a real `.ralph-done` file written by the stubbed `claude` function, which mimics the skill writing it. No direct skill test.

**Module 2 (loop core):** verify that after N iterations, N commits exist in the test repo, each with the expected commit message prefix.

**Module 3 (inactivity monitor):** with stubbed `inotifywait` returning code 2 immediately, verify that `audio-play-oroshi` was called exactly once even if the monitor loop ran multiple times.

**Module 4 (PRD completion check):** verify that with a `prd.json` where all issues are `"complete"`, the loop exits after 1 iteration even when `--iterations 10` is passed.

Prior art: `scripts/bin/__tests__/git-worktree-project.bats` and `scripts/bin/__tests__/oroshi-prompt-path-worktree.bats` — both use `run zsh -c` with temporary git repos and inline env overrides.

## Out of Scope

- **`--print` / headless mode:** running Claude without a visible TUI is not in scope. The user explicitly requires the ability to intervene during any iteration.
- **Parallel iterations:** running multiple issues simultaneously is not in scope. Issues are processed sequentially.
- **Timeout-based kill:** killing Claude after a fixed duration is not in scope. The inactivity alert is advisory only; the user decides whether to intervene or let Claude continue.
- **Automatic push:** the loop commits but does not push. Pushing remains a manual step.
- **prd.json schema enforcement:** the loop reads `status` fields from `prd.json` but does not validate or enforce the schema. Ralph is responsible for keeping `prd.json` correct.

## Further Notes

The `ralph-timeout.mp3` sound file must be created manually at the expected path in `config/audio/sounds/` before the inactivity monitor is functional. The loop degrades gracefully if the file is absent (the `audio-play-oroshi` call fails silently).
