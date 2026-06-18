## Issue 01 — Harden helper
### Redundant teardown() in helper.bats
```bash
teardown() {
  bats_cleanup
}
```
**Problem:** Now a no-op override of the identical default from helper.
**Reason skipped:** Intentional — mirrors the 120 existing files and validates the override model per acceptance criteria.
