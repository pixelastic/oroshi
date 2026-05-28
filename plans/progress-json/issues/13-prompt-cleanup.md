Update the zsh prompt to use `plans-progress` and delete the dead `commit-writer` skill.

## What to build

Two cleanup tasks:

**1. Prompt integration:** Update `tools/term/zsh/config/prompt/git.zsh` function `oroshi-prompt-populate:git_issues_prd` to call `plans-progress` instead of `ralph-progress`. No other logic changes — the output format is identical.

**2. Delete commit-writer skill:** Remove `tools/ai/claude/config/skills/commit-writer/` entirely. It's dead code superseded by `git-commit-message.js`.

## Acceptance criteria

- [ ] Prompt function calls `plans-progress` instead of `ralph-progress`
- [ ] Prompt still displays `done/total` in the correct color
- [ ] `commit-writer` skill directory is deleted
- [ ] No references to `ralph-progress` remain in prompt code

## Blocked by

- 02 (needs `plans-progress` to exist)
