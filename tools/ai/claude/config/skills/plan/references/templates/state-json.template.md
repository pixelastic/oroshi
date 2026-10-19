# state.json

Format: a JSON object. `plan-start` creates it with `branchedAt` set and
`issues: []`. Add one entry per issue to `issues`:

```json
{
  "branchedAt": "f587ebda8b7511c9812a5d497d10f2f7f9f9e297",
  "issues": [
    {
      "id": "01",
      "issue": "issues/01-slug.md",
      "done": true,
      "blocked_by": [],
      "recap": "short summary of what was done"
    },
    {
      "id": "02",
      "issue": "issues/02-slug.md",
      "done": false,
      "blocked_by": ["01"]
    }
  ]
}
```

- `branchedAt`: commit the worktree was at when `plan-start` ran (its current
  commit); set by `plan-start`, never edit
- `issues`: array of issue objects, one per issue
- `id`: 2-digit string, issue number (e.g. `"01"`)
- `issue`: relative path to the issue markdown file in the `issues/`
  subdirectory
- `done`: boolean, `false` initially; set to `true` by the ralph skill after
  implementation
- `blocked_by`: array of id strings — other issues that must be done before this
  one
- `recap`: string, present only when `done: true`; short summary of what was
  done (primary input for commit message generation)
