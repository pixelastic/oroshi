## TLDR

Add file location guidance to `skill-writer` and add `skill-writer` to Ralph's Step 3 examples.

## What to build

Four edits across two skill files:

1. **`skill-writer` description** — broaden from "Use when creating or updating a discipline-enforcing skill" to "Use when creating or updating skills."
2. **`skill-writer` Overview** — add a *File Locations* block explaining that skill files are tracked inside the repository (under the skills config directory), that `~/.claude/skills/` contains symlinks pointing to the main branch (not the current worktree), and that agents must always edit the tracked copy inside the git root.
3. **`skill-writer` Common Rationalizations** — add a row for: rationalization "this is where the skill file lives, I'll edit it there" → reality "that path is a symlink to the main branch, not the current worktree; edit inside the git root."
4. **`ralph` Step 3** — add `skill-writer` to the parenthetical example list alongside `zsh-writer` and `js-writer`.

## Acceptance criteria

- [ ] `skill-writer` description no longer says "discipline-enforcing"
- [ ] `skill-writer` Overview contains a File Locations block with the tracked path and symlink warning
- [ ] `skill-writer` Common Rationalizations table has a row addressing the global-path mistake
- [ ] `ralph` Step 3 point 1 lists `skill-writer` in its examples
