## Issue 01 — Migrate git-branch-rename

### Standards: raw `git branch --move` instead of a helper

```zsh
git branch --move "$@"
```

**Problem:** calling-commands.md says prefer existing helpers over raw porcelain.
**Reason skipped:** We are creating this helper. There is no pre-existing wrapper to call — the raw git command is the correct implementation here.

### Standards: `cd "$BATS_GIT_DIR"` repeated per-test instead of in `setup()`

```bats
@test "no args: fails with non-zero exit code" {
  cd "$BATS_GIT_DIR"
  ...
}
```

**Problem:** testing.md pattern shows `cd` done in `setup()`.
**Reason skipped:** `git-branch-current.bats` (prior art) uses the same per-test `cd` pattern. Consistent with established practice in this repo.
