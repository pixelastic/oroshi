## TLDR

Add lint and end steps to the slack-writer skill.

## What to build

Update `tools/ai/claude/config/skills/slack-writer/SKILL.md` to add:

- **Step 3 — Lint**: run `prose-lint` on the draft, read the JSON violations, fix them, re-lint until clean
- **Step 4 — End**: run `slack-writer-end` to copy the final draft to clipboard

The lint step follows the same pattern as zsh-writer Step 5 and js-writer Step 5: run linter, fix violations, re-run until clean.

## Acceptance criteria

- [ ] SKILL.md contains Step 3 — Lint with `prose-lint` invocation
- [ ] SKILL.md contains Step 4 — End with `slack-writer-end` invocation
- [ ] Checklist updated to include lint and clipboard steps
