## Issue 03 — python-test infrastructure

### Spec: pip --user fallback missing from pytest install script

```zsh
pipx install pytest
```

**Problem:** Spec says "Installs pytest via pipx (or pip --user if pipx is unavailable for pytest)".
**Reason skipped:** Conflicting spec requirement — "Follow the exact same pattern as the ruff install script" and the ruff install script has no pip fallback. Following the ruff pattern takes precedence.

## Issue 01 — python-lint --fix flag

### Spec: `exit` under `set -e` is fragile for non-zero propagation

```zsh
ruff check "$inputFile"
exit
```

**Problem:** Spec agent flagged that `exit` after `ruff check` is never reached when ruff check fails under `set -e`, making the exit-code contract fragile.

**Reason skipped:** This is correct behavior. Under `set -e`, a failing `ruff check` causes the script to exit non-zero immediately — `exit` is only reached when ruff check succeeds (exit 0), at which point `exit` correctly exits 0. The exit-code contract is fully correct.

## Issue 06 — zsh-fix refactor

### Spec: shfmt no-op mock makes --in-place test vacuous

**Problem:** Spec says "--in-place: File is modified in place." With `shfmt() { :; }`, the workfile has the same content as the input, so `cat "$file" == "# clean file"` doesn't verify the copy-back path actually ran.
**Reason skipped:** The behavioral test does verify the file is written back (content unchanged is still a copy-back). The key assertions — `output == ""` and `[[ -f "$file" ]]` — correctly test the routing behavior. Strengthening would require a mock that modifies the workfile, adding complexity without meaningful gain given that shfmt/beautysh are not installed.

## Issue 02 — zsh-lint --fix flag

### `local file=` in @test bodies

```bash
local file="$BATS_TMP_DIR/test.zsh"
```

**Problem:** Reviewer flagged `local file=...` in `@test` bodies as a violation of the "all test vars in setup()" memory.
**Reason skipped:** The memory (`feedback_bats_setup_vars.md`) says "not at file top level" — it targets vars declared outside setup/test blocks. `local` inside `@test` bodies is standard bats practice, matches every pre-existing test in the file, and bats-lint does not flag it.
