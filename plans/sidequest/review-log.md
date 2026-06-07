## Issue 01 — kitty-helper-claude-start

### `local` at script top-level flagged as hard violation

```zsh
local projectRoot="$(git-directory-root)"
local prompt="$1"
```

**Problem:** Reviewer flagged `local` at script top-level as invalid in zsh (only valid inside functions).

**Reason skipped:** In zsh, `local` IS valid at the top-level of a script — the script body is treated as an implicit function scope. This is an established codebase pattern present in `kitty-window-toggle-claude` and other kitty bin scripts. The deleted `kitty-run-claude` used the same pattern intentionally.

## Issue 02 — Add --cmd flag to kitty-tab-create

### "bats_mock kitty@ never called"

```bash
cat >"$BATS_TMP_DIR/mock.zsh" <<'EOF'
kitty@() { echo "$*" >"$BATS_TMP_DIR/kitty-args"; }
EOF
bats_run_zsh "$CURRENT" "My Tab"
```

**Problem:** Reviewer flagged that `bats_mock "kitty@"` was never called, suggesting the mock isn't active.

**Reason skipped:** `bats_mock` uses `declare -f`, which rejects `@` as an identifier in bash. Writing directly to `$BATS_TMP_DIR/mock.zsh` is the correct workaround — `bats_run_zsh` explicitly sources that file before running the script. Verified: tests were correctly RED pre-implementation and GREEN post-implementation, proving the mock intercepts `kitty@` calls.

### "[ ] vs [[ ]] for status checks"

```bash
[ "$status" -eq 0 ]
```

**Problem:** Reviewer flagged single-bracket form as inconsistent with zsh-writer style.

**Reason skipped:** All existing bats tests in this project use `[ "$status" -eq 0 ]` (see `kitty-helper-claude-start.bats`, `ralph.bats`). Single bracket is the established project convention for numeric status checks.
