## PRD

[Merge main into reorg](PRD.md)

## What to do

Resolve conflicts in 3 bats test files under `tools/term/zsh/config/prompt/__tests__/`.

---

### `git.zsh.bats` (R082)

**Main** deleted 4 tests for `git_worktree_branch` (moved to the context-badge PRD work) and kept the rest.
**Reorg** updated path references in all tests: `~/.oroshi/config/term/zsh/` → `$OROSHI_ROOT/tools/term/zsh/config/` (or equivalent).

**Resolution:** Start from main's version (fewer tests), apply reorg's path updates to the kept tests.

```bash
git show main:config/term/zsh/prompt/__tests__/git.zsh.bats \
  > tools/term/zsh/config/prompt/__tests__/git.zsh.bats
# Then apply path updates as reorg did
```

---

### `index.zsh.bats` (R071)

**Main** added one new test:
```bash
@test "git_worktree_branch is not in OROSHI_ASYNCHRONOUS_PROMPT_PARTS" {
  run grep 'git_worktree_branch' "$OROSHI_ROOT/config/term/zsh/prompt/index.zsh"
  [ "$status" -eq 1 ]
}
```
Note: this test still references the old `config/` path inside `$OROSHI_ROOT`. After reorg the file is at `tools/term/zsh/config/prompt/index.zsh`.
**Reorg** updated path references in existing tests.

**Resolution:** Merge both changes. For main's new test, fix the path:
```
$OROSHI_ROOT/config/term/zsh/prompt/index.zsh
→ $OROSHI_ROOT/tools/term/zsh/config/prompt/index.zsh
```

---

### `path.zsh.bats` (R084)

**Main** changed some `source ~/.oroshi/config/term/zsh/prompt/path.zsh` to `source $OROSHI_ROOT/config/term/zsh/prompt/path.zsh` and added new tests for worktree path display.
**Reorg** updated all sources to use `tools/` path.

**Resolution:** Merge both changes. For the new tests from main, change:
```
$OROSHI_ROOT/config/term/zsh/prompt/path.zsh
→ $OROSHI_ROOT/tools/term/zsh/config/prompt/path.zsh
```

---

## Acceptance criteria

- [ ] No `<<<<<<` markers in any of the 3 files
- [ ] All `source` calls use `tools/term/zsh/config/prompt/` path
- [ ] Main's deleted `git_worktree_branch` tests are absent from `git.zsh.bats`
- [ ] Main's new `index.zsh.bats` test is present with corrected `tools/` path
- [ ] Main's new `path.zsh.bats` worktree tests are present with corrected `tools/` paths
- [ ] `rtk bats tools/term/zsh/config/prompt/__tests__/` passes (or skips gracefully)

## Blocked by

issue-001
