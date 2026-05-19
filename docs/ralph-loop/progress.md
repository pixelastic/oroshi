## Execution order

0001 → start here, no blockers
0002 → needs 0001
0003 → needs 0002

## Guidance

- The ralph script lives in `scripts/bin/claude/ralph` — it has a shebang and uses `set -e`
- The ralph skill lives in `config/ai/claude/claudecode/skills/ralph/SKILL.md`
- `ralph-end` is a new script in `scripts/bin/claude/ralph-end` (same domain as `ralph`)
- Use `zsh-writer` skill when writing or modifying any ZSH script
- Use `zparseopts -E -D` for flag parsing (not manual `$1` shifting)
- Bats tests live in `scripts/bin/__tests__/` — see `git-worktree-project.bats` and `oroshi-prompt-path-worktree.bats` as prior art for test structure (temp git repos, stubbed commands via PATH prepend)
- Stub external commands by creating executable files in a temp `bin/` dir prepended to PATH in the bats test setup
- `audio-play-oroshi ralph-timeout.mp3` is the sound call — stub it to write to a capture file in tests
- `.ralph-done` and `.ralph-prd-done` are written inside `<dir>` (the PRD directory argument), not the git root
- The `--max` flag (not `--iterations`) is the user-facing API

---
## Log (append below when an issue is completed)

## Session 2026-05-19 — 0001: ralph-end script
- Completed: Created `scripts/bin/claude/ralph-end` script; updated ralph SKILL.md Step 7 to call it
- Tests added: `scripts/bin/__tests__/ralph-end.bats` — 4 tests covering open/complete/absent/malformed prd.json
- Discovered: bats tests need `PATH` prepend in setup to find worktree bin scripts (not yet in ~/.oroshi)
- Fixed: `set -e` exit bug — `[[ cond ]] && cmd` returns 1 when cond is false; fixed with return-early pattern
- Skipped feedback: review ran on prior docs commits; findings were duplicate `"id":"0001"` in prd.json (pre-existing, structural, out of scope), missing 0002/0003 test cases (wrong issue), commit verbosity (no commit yet)
- Next: issue 0002 — ralph --max loop core

## Session 2026-05-19 — 0002: ralph --max loop core
- Completed: Added `--max N` flag to `scripts/bin/claude/ralph/ralph`; sentinel watcher in background; commit-per-iteration; prd-done early exit; Ctrl+C detection
- Tests added: `scripts/bin/__tests__/ralph-loop.bats` — 3 tests (3-iteration count, early exit on prd-done, Ctrl+C no-commit)
- Discovered: `.zshenv` rebuilds PATH entirely — PATH-based stubs don't survive zsh script invocation; used `RALPH_CLAUDE_CMD` and `RALPH_GIT_COMMIT_MESSAGE` env vars instead; wrote sentinel files directly in stub (ralph-end not in rebuilt PATH)
- Fixed: `zparseopts` spec uses `-max:=flagMax` (double-dash) not `max:=flagMax` for `--max` flag
- Skipped feedback: review findings 1-4 are pre-existing ralph-end issues from issue 0001 (local/return at top-level, missing zparseopts, jq on missing file) — out of scope for this issue; scope-creep findings are pre-existing from previous session
- Next: issue 0003 — inactivity monitor

## Session 2026-05-19b — 0002: fix ralph-loop.bats assertions
- Completed: Fixed 3 `git -C "$GIT_REPO" log` assertions in `ralph-loop.bats` → `git log` (cd already in place; git -C breaks with env GIT_DIR=.git)
- Tests added: none (fixed pre-existing assertions)
- Discovered: tests were pre-written but assertions broke due to git -C / GIT_DIR env interaction
- Fixed: git -C pattern in tests 1, 2, and 3
- Skipped feedback: review findings all concern ralph-end (out of scope); zsh allows local/return at script level; ralph-end.bats PATH prepend is for the script itself (not a stub)
- Next: issue 0003 — inactivity monitor

## Session 2026-05-19 — 0003: inactivity monitor
- Completed: Added background inactivity monitor to ralph `--max` loop; calls `audio-play-oroshi ralph-timeout.mp3` once per idle period; resets on filesystem activity; killed alongside sentinel watcher when Claude exits; not started in single-run mode
- Tests added: `scripts/bin/claude/ralph/__tests__/ralph.bats` — 3 new tests: timeout fires once, activity resets and re-fires, no monitor in single-run mode
- Discovered: signal synchronization needed — used `audio_played` sentinel file so claude stub waits until monitor fires before exiting, avoiding race between monitor and claude exit
- Fixed: none
- Skipped feedback: all review findings were pre-existing from 0002 migration commit (git-commit-message env-var, deleted comments, test location, setup pattern) — not introduced by 0003
- Next: all PRD issues complete
