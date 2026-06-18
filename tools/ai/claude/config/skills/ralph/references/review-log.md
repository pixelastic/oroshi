# review-log.md Format

Create or append to `review-log.md` (path from `ralph-start` output) for each skipped feedback item:

```markdown
## Issue XX — <title>
### <feedback item title>
```<language>
<flagged code block>
```
**Problem:** <what the reviewer flagged>
**Reason skipped:** <why it was dismissed>
```

## Rules

- One `## Issue XX` heading per issue, even if multiple items are skipped.
- Each skipped item gets its own `### <title>` sub-section.
- The code block should contain exactly the flagged code — no surrounding context.
- **Reason skipped** must state a concrete rationale: out of scope, already tracked elsewhere, disagree + why.
