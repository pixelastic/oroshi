## Issue 02 — python-test-path

### `local` at script top-level and `return` in shebang script

```zsh
local filePath="$1"
...
  echo "$filePath"
  return
```

**Problem:** Reviewer flagged `local` and `return` as invalid at the top level of a `set -e` shebang script (should use plain assignment and `exit 0`).

**Reason skipped:** The stated prior art (`bats-test-path`) uses the exact same `local`/`return` pattern in a shebang script. `zsh-lint` returns `[]` on both files — no violation detected by the toolchain. Diverging from the prior art without a clear lint error or runtime failure is out of scope for this issue.

## Issue 05 — git-file-test Python branch

### Missing bats_disable_worktree_aware in new tests

```bats
setup() {
  bats_git_dir 'my-repo'
}
```

**Problem:** Standards agent flagged missing `bats_disable_worktree_aware` in `setup()`, claiming worktree autoloads won't be on fpath when tests `cd` outside the worktree.
**Reason skipped:** `git-file-lint.bats` (issue 04, same pattern, same `cd $BATS_GIT_DIR` usage) does not call `bats_disable_worktree_aware` and its tests pass. The memory note says it "avoids over-mocking" — not that it's required for basic fpath resolution. The new tests pass without it, and the existing setup in this file is the established pattern.

## Issue 03 — python-lint multi-file

### --json + --fix interaction

```zsh
if [[ $isFix == "1" ]]; then
  ...
  ruff check --quiet "$absFile" || exitCode=1
  ...
fi
```
**Problem:** Spec says "The `--fix` and `--json` flags continue to apply to each file in the batch" — reviewer flagged that `--json` is not applied when `--fix` is set.
**Reason skipped:** Pre-existing behavior. The original single-file script also ignored `--json` in fix mode. Fix mode is CLI-only (auto-reformats in place); JSON output is for Vim integration. The spec phrase means each flag still works on each file independently, not that they must compose together.
