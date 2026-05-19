# issue-XXX-slug.md

Replace `XXX` with the issue number.
Number issues in dependency order (blockers first) so you can reference real issue identifiers in the "Blocked by" field.
Generate `slug` from the issue title.

## Template

```markdown
## PRD

A reference to the parent PRD (if given, otherwise omit this section)

## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation.

Avoid specific file paths or code snippets — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it here and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Blocked by

- A reference to the blocking ticket (if any)

Or "None - can start immediately" if no blockers.
```
