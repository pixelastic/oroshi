## TLDR

Delete the dead `commit-writer` skill, superseded by `git-commit-message.js`.

## What to build

Remove `tools/ai/claude/config/skills/commit-writer/` entirely. It's dead code — all commit message generation goes through the `git-commit-message.js` Node.js script.

## Acceptance criteria

- [ ] `commit-writer` skill directory is deleted
- [ ] No references to `commit-writer` remain in the codebase
