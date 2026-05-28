## PRD

[Merge main into reorg](PRD.md)

## What to do

All conflicts are resolved. Stage remaining files and complete the merge commit.

```bash
# Verify no conflict markers remain anywhere
git grep -r "<<<<<<" . && echo "CONFLICTS REMAIN" || echo "Clean"

# Stage all resolved files
git add tools/ai/claude/config/settings.json
git add tools/ai/claude/config/hooks/preToolUse-Bash
git add tools/vim/nvim/config/config/filetypes/colors.lua
git add tools/ai/rtk/install
git add tools/term/zsh/config/prompt/__tests__/

# Complete the merge
git merge --continue
```

The commit message can stay as the default git merge message.

## Acceptance criteria

- [ ] `git grep -r "<<<<<<" .` returns nothing
- [ ] `git status` shows clean working tree
- [ ] `git log --oneline -3` shows the merge commit on top
- [ ] The merge commit has two parents: the reorg HEAD and main HEAD

## Blocked by

issue-002, issue-003, issue-004, issue-005, issue-006
