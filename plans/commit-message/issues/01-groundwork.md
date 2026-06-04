## TLDR

Ignore `COMMIT_HINT` in git and teach Ralph to write it after implementing an issue.

## What to build

Two non-code changes that set up the rest of the feature:

1. Add `plans/*/COMMIT_HINT` to `.gitignore` so the hint file never appears in `git status` or `git diff`.

2. Add a new sub-step to the DOCUMENT phase of the Ralph skill. After updating `state.json` and `GUIDANCE.md`, Ralph writes a `COMMIT_HINT` file in the plan directory. The content is free prose covering: what the issue aimed to do, what was actually done, the most important file-level changes, and a suggested `type(scope)`. Use `plan-directory` to resolve the path.

## Acceptance criteria

- [ ] `plans/*/COMMIT_HINT` is in `.gitignore`
- [ ] Ralph SKILL.md DOCUMENT step includes the COMMIT_HINT write sub-step
- [ ] The hint format guidance is clear enough that an agent can write a good hint without further instruction
