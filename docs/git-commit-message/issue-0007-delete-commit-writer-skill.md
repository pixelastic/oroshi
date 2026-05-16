## PRD

docs/git-commit-message/PRD.md

## What to build

Delete the `commit-writer` skill from `~/.claude/skills/commit-writer/`. Its
content is now hardcoded in the `git-commit-message` script and it has no
remaining callers.

Note: this directory is outside the repo — the agent must use a shell command
to remove it.

## Acceptance criteria

- [ ] `~/.claude/skills/commit-writer/` no longer exists
- [ ] No file in the repo references the `commit-writer` skill

## Blocked by

- issue-0003-script-core.md
