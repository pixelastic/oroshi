## Issue 03 — ralph-loop

### Spec: git-directory-root navigation is a "logic addition"

```zsh
local gitRoot="$(git-directory-root)"
cd "$gitRoot"
```

**Problem:** Spec says "extract the loop block from `ralph` verbatim — no logic changes." The `git-directory-root` navigation was shared setup code before the loop in `ralph`, not inside the loop block.

**Reason skipped:** Without navigating to git root, `git add --all` and `git commit` would fail in the extracted standalone function. This is a structural necessity (same pattern as `ralph-single.zsh`), not a logic change.

### Standards: `local commits` split from assignment in bats (SC2155)

```bats
local commits
commits="$(git -C "$GIT_REPO" log --oneline | wc -l)"
```

**Problem:** Memory rule says to combine `local`/assignment. Reviewer flagged initial combined form.

**Reason skipped:** The combined form `local commits="$(…)"` triggers SC2155 in shellcheck/bats-lint (bash context). The memory rule applies to ZSH functions only. Split form is correct for bats tests.

## Issue 02 — ralph-single

### Spec: bats_run_function not used

```bats
bats_run_zsh "$CURRENT" "$PRD_DIR"
```

**Problem:** Issue spec says "Write `ralph-single.bats` using `bats_run_function` (not `bats_run_script`)".

**Reason skipped:** `bats_run_function` is marked `DEPRECATED` in `tools/term/bats/config/helper` ("use `bats_run_zsh` with the full path to the autoload function instead"). The codebase migrated all tests to `bats_run_zsh` (commits `1a641105`, `47aa3f8a`). The actual prior art file `preToolUse-Bash-rtk.bats` uses `bats_run_zsh`. The spec was written before the migration.
