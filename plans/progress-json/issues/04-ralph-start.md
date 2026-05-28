## TLDR

New script that deterministically picks the next issue and outputs everything the ralph skill needs to start working.

## What to build

New script `ralph-start` that deterministically selects the next issue to work on and outputs everything the ralph skill needs to begin.

The script:
1. Takes an optional `<dir>` argument (defaults to `plans-directory` output)
2. Reads `state.json` from that directory
3. Finds the first issue (by id) where `done == false` and all `blocked_by` ids have `done == true`
4. Outputs a JSON object with absolute paths and the full issue entry from state.json

Output when an issue is available (exit 0):
```json
{
  "status": "next",
  "issue": { "id": "03", "issue": "issues/03-slug.md", "done": false, "blocked_by": ["01", "02"] },
  "paths": {
    "guidance": "/absolute/path/to/GUIDANCE.md",
    "state": "/absolute/path/to/state.json",
    "review_log": "/absolute/path/to/review-log.md",
    "spec": "/absolute/path/to/issues/03-slug.md"
  }
}
```

Output when all issues are done (exit 0):
```json
{
  "status": "done"
}
```

Exit 1 with error message when issues remain but all are blocked (deadlock).

## Acceptance criteria

- [ ] `ralph-start` outputs valid JSON with `status: "next"` and the correct issue
- [ ] Picks the first eligible issue by id (lowest id, not done, all blockers done)
- [ ] All paths in output are absolute
- [ ] `paths.spec` resolves the issue path from state.json relative to the plan directory
- [ ] Outputs `{ "status": "done" }` when all issues have `done: true`
- [ ] Exits 1 when remaining issues are all blocked
- [ ] Exits 1 when state.json is missing