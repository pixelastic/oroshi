# guidance-md.md

A file that bridges context windows across sessions. Split into two sections with
different ownership rules.

```markdown
## Guidance

Static instructions specific to this PRD: testing commands, file locations, code
conventions, prior art references. Written once by to-issues. Never modified by agents.

## Discoveries

Append-only section. After each issue, the ralph skill adds a subsection:

### Issue XX — short title
- Non-trivial finding 1
- Non-trivial finding 2
```

- **Guidance**: permanent instructions from the PRD author; agents read but never edit
- **Discoveries**: append-only log of non-obvious findings; agents add a new H3 block after each issue
