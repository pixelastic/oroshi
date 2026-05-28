## PRD

[Merge main into reorg](PRD.md)

## What to do

```bash
git merge main
```

Git's rename detection (threshold 50%) auto-resolves the 49 R100 files — those were moved by reorg but their content wasn't touched, so main's changes apply cleanly to the new `tools/` paths.

After the command, check what's left:

```bash
git status | grep "both modified\|rename/delete\|deleted by them\|deleted by us"
```

Expected conflicts (do NOT resolve yet — separate issues handle each group):

| Group | Files |
|---|---|
| issue-002 | `tools/ai/claude/config/settings.json` |
| issue-003 | `tools/ai/claude/config/hooks/preToolUse`, `preToolUse-Bash`, `preToolUse-Skill`, `preToolUse-mcp`, `sessionStart` |
| issue-004 | `tools/term/zsh/config/prompt/__tests__/git.zsh.bats`, `index.zsh.bats`, `path.zsh.bats` |
| issue-005 | `tools/vim/nvim/config/config/filetypes/colors.lua` |
| issue-006 | `tools/ai/rtk/install` |

## Acceptance criteria

- [ ] `git merge main` runs without aborting
- [ ] `git status` shows the merge in progress (not a clean tree yet)
- [ ] No unexpected conflicts outside the groups listed above

## Blocked by

None — start here.
