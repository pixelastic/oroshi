## Issue 02 — migrate direct invocation

### post-commit.bats: bare name vs full path

```bats
bats_run_zsh "$BATS_TEST_DIRNAME/../post-commit"
```

**Problem:** Both reviewers flagged this as inconsistent — migration rule says use bare script name, but this uses full path inline.

**Reason skipped:** `scripts/yarn/hooks/` is not in `$PATH` (only `scripts/bin/**/` is added by `oroshi-reload-path`). Using `bats_run_zsh "post-commit"` would fail with "command not found". The full-path inline form is the only correct option for this file.

## Issue 03 — migrate source-prefix

### ~11 files unaddressed (spec estimated ~15, diff covers 4)

```
# The "~15" count in the issue spec was an estimate.
# After exhaustive grep of all CURRENT= assignments in *.bats files,
# only 4 files have CURRENT pointing to a .zsh autoload path:
#   - zshenv-guest.bats, zshenv-host.bats, index.bats, zsh-lint-custom.bats
# The remaining CURRENT= assignments are either:
#   - $BATS_TMP_DIR/caller.zsh temp files (Issue 04)
#   - binary scripts without .zsh extension (Issue 02)
#   - already migrated (bats-lint-custom.bats)
#   - string literals inside test arguments (rule-no-top-level-var.bats)
```

**Problem:** Spec reviewer flagged ~11 files as unaddressed.
**Reason skipped:** Scope was correct at 4 files. The estimate was wrong, not the implementation.
