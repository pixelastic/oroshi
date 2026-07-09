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
