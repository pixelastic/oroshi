## PRD

docs/git-commit-message/PRD.md

## What to build

Simplify `claude-print` by replacing the `--session-id` + `rm -f` session file
dance with `--no-session-persistence`. This saves ~1s for all callers
(`translate`, `review`) by eliminating session file writes to disk.

Changes:
- Add `--no-session-persistence` to the `claude` invocation in `claude-print`
- Remove the `--session-id` flag and the two `rm -f` calls around it
- Remove the `OROSHI_CLAUDECODE_STOP_SOUND` unset (keep sound logic intact)

## Acceptance criteria

- [ ] `claude-print` no longer references `--session-id` or `rm -f`
- [ ] `--no-session-persistence` is passed to the `claude` invocation
- [ ] `translate` and `review` still work correctly
- [ ] No session `.jsonl` files are left behind after a `claude-print` call

## Blocked by

None - can start immediately
