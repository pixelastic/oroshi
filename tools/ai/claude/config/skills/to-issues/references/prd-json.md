# prd.json

Format: a JSON array of objects, one per test case:

```json
[
  {
    "id": "0001",
    "description": "one-sentence description of what is being tested",
    "steps": [
      "step 1",
      "step 2",
      "step 3"
    ],
    "passes": false
  }
]
```

- `id`: the issue number this test belongs to (e.g. `"0001"`)
- `description`: matches the test description in the Testing Decisions section
- `steps`: concrete, numbered reproduction steps — enough for a future agent to write the test without reading the PRD
- `passes`: always `false` initially; agents will update this to `true` when the test passes
