# XX-slug.md

Files live at `issues/XX-slug.md`.
Replace `XX` with the 2-digit issue number (01, 02…).
Number issues in dependency order (blockers first).
Generate `slug` from the issue title.

## Template

```markdown
## TLDR

One-line TLDR summarizing the issue.

## What to build

A concise description of this vertical slice.
Describe the end-to-end behavior, not layer-by-layer implementation.

Avoid specific file paths or code snippets — they go stale fast.
Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it here and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

## Behavioral Tests

What behaviors the tests must verify, grouped by scenario.
Test names are sentences.

**Skip if:** Issue is pure refactoring.

## Scaffolding Tests

What structural transformation the scaffolding test must verify.

**Skip if:** Issue adds only new behavior.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3


```
