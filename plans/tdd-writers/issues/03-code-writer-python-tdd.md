## TLDR

Add python-writer to code-writer's language list and mention TDD workflow expectation.

## What to build

In `tools/ai/claude/config/skills/code-writer/SKILL.md`, in the "Language-Specific Skills" section:

1. Add `python-writer` entry to the bullet list (alongside js-writer and zsh-writer).
2. Add one sentence after the list stating that all language-specific skills follow a RED → GREEN → REFACTOR → LINT workflow.

## Acceptance criteria

- [ ] python-writer listed alongside js-writer and zsh-writer
- [ ] One-sentence TDD workflow expectation present after the list
