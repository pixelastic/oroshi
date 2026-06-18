# COMMIT_HINT.md Format

## Template

```
## Goal
<One sentence: the problem being solved or objective being pursued (the Why).>

## Done
<What was concretely built or changed to achieve that goal (the How). Note any deviations from the goal.>

## Key files
- `path/to/file` — one-line reason this file matters
- `path/to/file` — one-line reason this file matters

## Suggested type(scope)
`type(scope)` — e.g. `feat(git-commit-message)`, `chore(gitignore)`, `plan(commit-quality)`
```

## Rules

**Goal is the why.**
The problem being solved, or the objective. Not what was changed, but why the change was needed.

**Done is the how.**
Concrete changes made to achieve the goal.

**No issue numbers or plan reference.**
Never describe plan status ("closed issue 03", "finished step 2").
Issue numbers are plan-internal. Once the plan directory is deleted, they are untraceable.
Write "added X behavior" not "closed issue 03".

**Be specific enough that an agent can write a good commit message without re-reading the diff.**

## Rationalizations

| Rationalization | Reality |
|---|---|
| "I mentioned issue 03 to be specific" | Issue numbers are ephemeral. Describe what was built, not which issue was closed. |
