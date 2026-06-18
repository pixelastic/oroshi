## TLDR

Harden `bats_cleanup` against empty `$BATS_TMP_DIR` and add a default `teardown()` to the shared helper.

## What to build

Two changes in `tools/term/bats/config/helper`:

1. **Guard `bats_cleanup`:** Add an early return when `$BATS_TMP_DIR` is empty or unset. Without this, the default teardown would invoke `rm -rf ""` on stateless test files, causing bash to error and BATS to mark those tests as failed.

2. **Default `teardown()`:** Define `teardown() { bats_cleanup; }` after the existing function definitions. BATS resolves functions by name — the last definition wins. Since the helper is loaded via `bats_load_library` before the test file's own definitions, a test file's `teardown()` naturally overrides this default (Model A — override).

No default `setup()` is added — setup remains explicit.

## Behavioral Tests

Extend the existing `tools/term/bats/config/__tests__/helper.bats`.

**bats_cleanup guard:**
- returns 0 when BATS_TMP_DIR is unset
- returns 0 when BATS_TMP_DIR is empty string
- removes directory when BATS_TMP_DIR points to an existing directory

**default teardown:**
- temp directory is removed after test when no custom teardown is defined

## Acceptance criteria

- [ ] `bats_cleanup` returns 0 when `$BATS_TMP_DIR` is unset or empty
- [ ] `bats_cleanup` still removes the directory when `$BATS_TMP_DIR` is set
- [ ] A test file loading the helper with no `teardown()` gets automatic cleanup
- [ ] Existing tests pass unchanged (the 120 files with explicit `teardown() { bats_cleanup; }` still work via override)
- [ ] `bats helper.bats` passes
