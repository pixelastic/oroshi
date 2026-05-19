# progress.md

A persistent file that bridges context windows. Agents read at session start,
append at end. Without it a new session starts with half-implemented features
and no record of what happened.

```markdown
## Execution order

<issue-id> → start here, no blockers
<issue-id> → needs <dep-id> + <dep-id>

## Guidance

Project-specific instructions agents must follow: where files go, which patterns
to use, what tooling is available. Written once; never modified by agents.

---
## Log (append below when an issue is completed)

YYYY-MM-DD — <issue-id> — DONE (N/N tests pass)

## Session notes — YYYY-MM-DD

### Completed
- <issue-id> (N/N tests pass)
  - path/to/file/created-or-modified

### Issues discovered and resolved
- Brief description of unexpected problems and how they were fixed.

### Up next (unblocked)
- <issue-id> (reason it is now unblocked)
```

- **Execution order**: dependency graph for all issues; agents pick the first unblocked issue
- **Guidance**: permanent instructions from the author; agents read but never edit this section
- **Log**: one line per completed issue; agents append a line when they finish
- **Session notes**: detailed record of what happened — files changed, bugs hit, patterns discovered, what's next; agents append a new block each session
