## TLDR

Create the `guidance-md.md` reference doc that defines the format for agent guidance and accumulated discoveries.

## What to build

Create `references/guidance-md.md` in the to-issues skill directory. This replaces the old `references/progress-md.md`.

The file has two sections:

```markdown
## Guidance

Static instructions specific to this PRD: testing commands, file locations, code conventions, prior art references. Written once by to-issues. Never modified by agents.

## Discoveries

Append-only section. After each issue, the ralph skill adds a subsection:

### Issue XX — short title
- Non-trivial finding 1
- Non-trivial finding 2
```

Remove the old `references/progress-md.md`.

## Acceptance criteria

- [ ] `references/guidance-md.md` exists with the two-section format
- [ ] Documents that `## Guidance` is static and `## Discoveries` is append-only
- [ ] Shows the H3 per-issue format for discoveries
- [ ] `references/progress-md.md` is removed