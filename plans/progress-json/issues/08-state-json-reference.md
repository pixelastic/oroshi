Create the `state-json.md` reference doc that defines the new schema for plan state tracking.

## What to build

Create `references/state-json.md` in the to-issues skill directory. This replaces the old `references/issues-json.md`.

The new schema is one entry per issue (not per test case):

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

- `id`: 2-digit string, issue number
- `issue`: relative path to the issue markdown file in the `issues/` subdirectory
- `done`: boolean, `false` initially, set to `true` by the ralph skill after implementation
- `blocked_by`: array of id strings referencing other issues that must be done first
- `recap`: string, appears only when `done: true`, short summary of what was done (primary input for commit message generation)

Remove the old `references/issues-json.md`.

## Acceptance criteria

- [ ] `references/state-json.md` exists with the schema above
- [ ] Documents all fields including `recap` (post-implementation only)
- [ ] `references/issues-json.md` is removed

## Blocked by

None — can start immediately
