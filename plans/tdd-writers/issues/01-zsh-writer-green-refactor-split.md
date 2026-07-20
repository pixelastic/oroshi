## TLDR

Split zsh-writer Step 3 into GREEN (Step 3) + REFACTOR (Step 4), renumber Lint to Step 5.

## What to build

In `tools/ai/claude/config/skills/zsh-writer/SKILL.md`:

1. Replace Step 3 ("Write the code") with a new Step 3 ("Make it work") that mirrors js-writer's wording: "Write the simplest code that makes the test pass. No patterns yet — just correct behavior." Include `bats` run command.
2. Add Step 4 ("Refactor") with Goal/Exit criterion matching js-writer's Refactor step. Move the pattern table and code example from old Step 3 here. Add `bats` run reminder.
3. Renumber old Step 4 ("Lint the file") to Step 5. Content unchanged.
4. Add `- [ ] Tests still pass after refactor` to the Checklist.

Reference `js-writer` Step 3–4 and `python-writer` Step 4–5 for exact wording and structure.

## Acceptance criteria

- [ ] Step 3 is "Make it work" — minimal code, no patterns, run bats
- [ ] Step 4 is "Refactor" — pattern table, code example, run bats
- [ ] Step 5 is "Lint the file" — unchanged content
- [ ] Checklist contains "Tests still pass after refactor"
- [ ] Goal/Exit criterion wording matches js-writer and python-writer
