## Issue 02 — pytest RTK filter

### match_command uses `( |$)` instead of `\b`

```toml
match_command = "^python-test( |$)"
```

**Problem:** Spec says `matches ^python-test\b`; implementation uses `( |$)`.
**Reason skipped:** GUIDANCE.md Issue 01 discovery explicitly documents that `\b` incorrectly matches `python-test-something` (hyphen is non-word char); `( |$)` is the established pattern for hyphenated commands in this codebase. Guidance supersedes spec wording.
