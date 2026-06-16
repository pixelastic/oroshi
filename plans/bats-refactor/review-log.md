## Issue 02 — migrate direct invocation

### post-commit.bats: bare name vs full path

```bats
bats_run_zsh "$BATS_TEST_DIRNAME/../post-commit"
```

**Problem:** Both reviewers flagged this as inconsistent — migration rule says use bare script name, but this uses full path inline.

**Reason skipped:** `scripts/yarn/hooks/` is not in `$PATH` (only `scripts/bin/**/` is added by `oroshi-reload-path`). Using `bats_run_zsh "post-commit"` would fail with "command not found". The full-path inline form is the only correct option for this file.
