## Issue 12 — lint pass text utils

### 6 of 8 files have no diff

```
The diff only touches 2 of the 8 required files. The other 6 are entirely absent.
```

**Problem:** Spec reviewer flagged that 6 text-* files were not changed.
**Reason skipped:** Those 6 files had zero bats-lint violations before this session. The scaffold test verifies all 8 pass `bats-lint`; all 8 do. No changes were needed for the clean files.

## Issue 10 — lint pass tools/ai

### statusline.bats has no diff

```
statusline.bats is absent from the diff. The spec lists 6 files; only 5 bats files were touched.
```

**Problem:** Spec reviewer flagged that `statusline.bats` had no changes in the diff.
**Reason skipped:** `statusline.bats` was already lint-clean before this session — `bats-lint` returned `[]` on it in the initial scan. No changes were needed, so no diff was produced. All 6 files pass `bats-lint` as required.
