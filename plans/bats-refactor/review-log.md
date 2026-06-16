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

## Issue 04 — eliminate temp-file wrappers

### `export MOCK_OVERRIDE` in setup() flagged as deprecated pattern

```bats
setup() {
  bats_tmp_dir
  export MOCK_OVERRIDE="$BATS_TMP_DIR/mock.zsh"
  printf "hookDir='%s'\nsource '%s'\n" "$hooksDir" "$SCRIPT" > "$BATS_TMP_DIR/mock.zsh"
}
```

**Problem:** Standards reviewer flagged `export MOCK_OVERRIDE` as the deprecated caller.zsh workaround pattern. Spec reviewer noted it was outside the spec's explicit instructions.

**Reason skipped:** `bats_tmp_dir` never sets `MOCK_OVERRIDE`. Without it, the zshenv guard (`if [[ $MOCK_OVERRIDE != "" ]]`) skips mock.zsh entirely and the sourced function is not found (exit 127). These two tests have no `bats_mock` call that would set it automatically. Adding `export MOCK_OVERRIDE` directly is identical to what `bats_mock_oroshi_root` does internally — it's the correct minimal fix. The "deprecated pattern" refers to `caller.zsh` as a temp script, not to the `MOCK_OVERRIDE` env var itself.

### `path.bats` — `local script=` in test body vs setup()

**Problem:** `feedback_bats_setup_vars.md` says all test vars go in `setup()`. The three tests each declare `local script="$BATS_TMP_DIR/script.zsh"`.

**Reason skipped:** The spec explicitly says "keep it as a `local script=` variable inside the test body" for complex temp scripts. Spec beats the general var-placement rule here.

### `path.bats` — temp script file instead of `sourcePrefix` pattern

**Problem:** Standards reviewer flagged that the sourcePrefix pattern is preferred for sourced functions.

**Reason skipped:** The sourcePrefix pattern applies to sourcing a `.zsh` file then calling a single function. The `path.bats` scripts are multi-statement one-liners that set env vars, source path.zsh, call the function, and echo output — they cannot be reduced to `sourcePrefix && fn`. The spec explicitly authorizes `local script=` + `bats_run_zsh "source $script"` for this case.
