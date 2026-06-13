## Issue 01 — kitty-helper-claude-start fallback

### `set -e` + `|| true` anti-pattern

```zsh
claude "${args[@]}" || true
```

**Problem:** Reviewer flagged that `|| true` defeats the purpose of `set -e`, making the error protection decorative.

**Reason skipped:** GUIDANCE.md explicitly documents `|| true` as the correct pattern for absorbing exit codes in this script (`|| true` to absorb exit codes; plain `zsh` (no `exec`) as fallback). This is the user's stated convention for this codebase.
