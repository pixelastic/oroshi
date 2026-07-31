# Prose Linting

Vocabulary for the prose-lint toolchain (Vale wrapper, profiles, severity levels).

## Language

**Error**:
A violation that is always wrong — no ambiguity, no edge case.
_Avoid_: bug, blocker, critical

**Warning**:
A violation that is a priori correctable but may have legitimate edge cases requiring judgement.
_Avoid_: issue, problem

**Suggestion**:
A violation that would improve the prose but is too hard to systematically apply.
_Avoid_: hint, info, note

**Profile**:
A named Vale configuration (e.g. default, blog) built by merging source overrides on top of the default base.
_Avoid_: config, preset, ruleset

## Relationships

- A **Profile** contains zero or more rules at each severity level: **Error**, **Warning**, **Suggestion**
- An **Error** must reach zero before the agent stops iterating
- A **Warning** should be attempted but may survive after review
- A **Suggestion** is informational — the agent is not required to act on it

## Flagged ambiguities

- "rule" vs "violation": a rule is the definition (e.g. write-good.Weasel), a violation is a specific match in text. Both map to one of the three severity levels.

## Example dialogue

> **Dev:** "prose-lint flags 'several' as an **Error** — should the agent fix it?"
> **Domain expert:** "Yes, always. **Errors** are unambiguous — find a precise alternative."
>
> **Dev:** "'aggregate' is flagged as a **Warning** — but it's the correct SQL term here."
> **Domain expert:** "Then leave it. **Warnings** allow edge cases when the word is justified."
>
> **Dev:** "'be compressed' is passive voice, flagged as **Suggestion**."
> **Domain expert:** "Ignore it. **Suggestions** are nice-to-have, not obligations."
