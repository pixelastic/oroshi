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

## Issue 03 — sidequest-end baseline tests

### "Inline function + bats_mock is wrong mock strategy"

```bash
clipboard-write() { cat >"$BATS_TMP_DIR/clipboard-in"; }
bats_mock clipboard-write
```

**Problem:** Spec reviewer flagged combining an inline function definition with `bats_mock` as incorrect, claiming `bats_mock` would override the inline function and break the stdin capture logic.

**Reason skipped:** This is the established project pattern — `kitty-tab-create.bats` uses the same approach (define stub function, then call `bats_mock`). Tests pass, confirming the mock correctly intercepts `clipboard-write` stdin.

## Issue 04 — sidequest orchestrator script

### Spec: --cmd value may be two separate words instead of one quoted string

```zsh
local cmd="kitty-helper-claude-start"
[[ "$prompt" != "" ]] && cmd="$cmd $prompt"
kitty-tab-create "$slug" --cwd "$worktreePath" --cmd "$cmd" $focusFlag
```

**Problem:** Reviewer noted the test echoes all args as a flat string via `$*`, so it doesn't prove that `kitty-tab-create` receives `--cmd` as a single compound value.

**Reason skipped:** `"$cmd"` is quoted, so zsh passes it as one argument to `kitty-tab-create`. `zparseopts --cmd:=flagCmd` captures the next token (`flagCmd[2]`), which is the full string `"kitty-helper-claude-start @/tmp/fix-ralph.md"`. Then `${=kittyCommand}` in `kitty-tab-create` does word-splitting to run the command correctly. False positive.

## Issue 05 — sidequest-end update

### Spec: scaffolding test not created
```
plans/sidequest/scaffold/05-sidequest-end-update.bats
```
**Problem:** Spec reviewer reported the scaffolding test was absent from the diff.
**Reason skipped:** The file was created and passes. `review-diff dirty` only shows tracked/staged changes; new untracked files are invisible to it — false positive.

### Standards: test var `file` in test body instead of setup()
```zsh
@test "valid file: calls sidequest with slug, --prompt @<filepath>, --no-focus" {
  file="$BATS_TMP_DIR/fix-ralph.md"
```
**Problem:** Reviewer flagged `file` should be in `setup()` per memory rule.
**Reason skipped:** The memory rule states "CURRENT and all test vars go inside setup(), not at file top level". The contrast is file-top-level vs setup(), not test-body vs setup(). Test-specific vars in the test body are consistent with all other tests in the project (sidequest.bats, etc.).
