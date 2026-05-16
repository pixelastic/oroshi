## PRD

[PRD — review-diff + review skill overhaul](./PRD.md)

## What to build

Rewrite `scripts/bin/ai/review` to:

1. Accept 0, 1, or 2 positional args (same signature as `review-diff`)
2. Run `review-diff "$@"`, save stdout to `/tmp/review-diff-<uuid>.md`
3. Call `claude-print "/review /tmp/review-diff-<uuid>.md"`

The named file pattern (`review-diff-<uuid>.md`) makes it unambiguous for the skill to detect and read directly via the Read tool, enabling chunking and search on large diffs.

## Acceptance criteria

- [ ] `review` accepts 0, 1, or 2 args and passes them through to `review-diff`
- [ ] Output is saved to `/tmp/review-diff-<uuid>.md` (uuid is unique per invocation)
- [ ] Claude is invoked with the filepath, not inline diff content
- [ ] Old single-commit-only behaviour is gone

## Blocked by

- issue-001, issue-002, issue-003, issue-004 (review-diff must be complete)
- issue-005 (SKILL.md must be approved so the shell script and skill are consistent)
