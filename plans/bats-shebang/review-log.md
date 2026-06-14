## Issue 02 — Strip shebangs

### Variable renames (LUA_LINT_CUSTOM etc. → CURRENT) are out-of-spec

```diff
-  LUA_LINT_CUSTOM="${BATS_TEST_DIRNAME}/../lua-lint-custom"
+  CURRENT="${BATS_TEST_DIRNAME}/../lua-lint-custom"
```

**Problem:** Spec only covers shebang/execute-bit removal and stale test deletion. Renaming script-path vars in lua/zsh test files was not mentioned.

**Reason skipped:** Required by `feedback_lint_preexisting.md` — pre-existing lint violations in touched files must be fixed. These files were touched (shebang removed), so `currentScriptVar` violations had to be addressed.

## Issue 01 — noShebang rule

### Missing `#!/usr/bin/env bats` on line 1 of `rule-no-shebang.bats`
```bats
bats_load_library 'helper'
bats_load_library 'rules-helper'
```
**Problem:** Standards reviewer flagged that all sibling rule test files have `#!/usr/bin/env bats` on line 1; this file has none.
**Reason skipped:** Intentional — the spec explicitly requires "no shebang on the test file itself" and the new rule flags shebangs in `.bats` files. The test file dogfoods the rule. Spec overrides peer convention.

### `run_this_rule` defined at file top level (not in `setup()`)
```bats
run_this_rule() {
  run_rule "${BATS_TEST_DIRNAME}/../rule-no-shebang.zsh" "batsLintRule_noShebang" "test.bats" "$@"
}
```
**Problem:** Standards reviewer noted `run_this_rule` is at top level, not inside `setup()`.
**Reason skipped:** The `setup()` memory applies to *variables*, not functions. All sibling test files define `run_this_rule()` at the file top level too — this is the established pattern.
