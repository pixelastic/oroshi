## Execution order

```
001-execute-merge          → no blockers
  ├── 002-settings-json    → needs 001 (independent of 003-006)
  ├── 003-hooks            → needs 001 (independent of 002, 004-006)
  ├── 004-prompt-tests     → needs 001 (independent of 002-003, 005-006)
  ├── 005-nvim-colors      → needs 001 (independent of 002-004, 006)
  └── 006-rtk-install      → needs 001 (independent of 002-005)
007-complete-merge         → needs 002 + 003 + 004 + 005 + 006
008-migrate-orphaned-files → needs 007
```

Issues 002–006 can be worked in any order or in parallel — each is a self-contained conflict resolution session. All must complete before 007.

## Guidance

**Running the merge:**
```bash
cd /home/tim/local/www/worktrees/oroshi--reorg
git merge main
```

**Inspecting a conflict:**
```bash
# What main had at the old path
git show main:config/ai/claude/hooks/preToolUse-Bash

# What reorg ended up with at the new path
git show HEAD:tools/ai/claude/config/hooks/preToolUse-Bash

# What the merge-base (common ancestor) had
git show ac4f1e64:config/ai/claude/hooks/preToolUse-Bash
```

**Staging a resolved file:**
```bash
git add <path>
```

**Completing the merge:**
```bash
git merge --continue
# or: git commit  (if --continue is not available)
```

**Checking for leftover conflict markers:**
```bash
git grep -r "<<<<<<" .
```

---
## Log (append below when an issue is completed)
