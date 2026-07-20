## TLDR

Align python-writer "Make it work" step wording with js-writer for consistency.

## What to build

In `tools/ai/claude/config/skills/python-writer/SKILL.md`, update Step 4 ("Make it work"):

- Change body text from "Write the simplest code that makes the test green. Don't optimize yet." to "Write the simplest code that makes the test pass. No patterns yet — just correct behavior."
- Keep Goal, Exit criterion, and run command unchanged.

## Acceptance criteria

- [ ] Step 4 body matches js-writer Step 3 wording
- [ ] Goal and Exit criterion unchanged
- [ ] Run command unchanged
