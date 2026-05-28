## PRD

plans/progress-json/PRD.md

## What to build

Update the `to-issues` skill (SKILL.md + reference files) to produce the new file structure:

**SKILL.md changes:**
- Step 4 creates: `state.json`, `GUIDANCE.md`, `issues/` directory with `XX-slug.md` files
- Remove reference to `progress.md` and `issues.json`
- Checklist updated to match new file names

**Reference file changes:**

Replace `references/issues-json.md` with `references/state-json.md`:
```json
[
  {
    "id": "01",
    "issue": "issues/01-slug.md",
    "done": false,
    "blocked_by": []
  }
]
```

Replace `references/progress-md.md` with `references/guidance-md.md`:
```markdown
## Guidance
(static instructions for this PRD)

## Discoveries
```

Update `references/issue-XX-slug.md`: issue number is 2-digit, file lives in `issues/` subdirectory (so filename is `XX-slug.md`, no `issue-` prefix).

Remove `references/prd-json.md` (old issues.json reference, duplicate).
Remove `references/issue-XXX-slug.md` (duplicate of issue-XX-slug.md).

## Acceptance criteria

- [ ] SKILL.md references state.json, GUIDANCE.md, and issues/ subdirectory
- [ ] `references/state-json.md` documents the new schema (id, issue, done, blocked_by)
- [ ] `references/guidance-md.md` documents the two-section format (Guidance + Discoveries)
- [ ] `references/issue-XX-slug.md` uses 2-digit ids and no `issue-` prefix
- [ ] Old references removed (prd-json.md, progress-md.md, issue-XXX-slug.md)
- [ ] Checklist mentions state.json, GUIDANCE.md, issues/ directory

## Blocked by

None — can start immediately
