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
