## Issue 01 — expect_json helpers
### Missing setup() in test file
```bats
bats_load_library 'helper'

# --- expect_json ---

@test "expect_json passes when jq path value matches expected string" {
```
**Problem:** Test file has no `setup()` function, convention suggests always having one.
**Reason skipped:** No shared state or variables to initialize; each test sets `output` inline. `setup()` would be empty.
