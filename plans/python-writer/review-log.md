## Issue 01 — python-lint --fix flag

### Spec: `exit` under `set -e` is fragile for non-zero propagation

```zsh
ruff check "$inputFile"
exit
```

**Problem:** Spec agent flagged that `exit` after `ruff check` is never reached when ruff check fails under `set -e`, making the exit-code contract fragile.

**Reason skipped:** This is correct behavior. Under `set -e`, a failing `ruff check` causes the script to exit non-zero immediately — `exit` is only reached when ruff check succeeds (exit 0), at which point `exit` correctly exits 0. The exit-code contract is fully correct.
