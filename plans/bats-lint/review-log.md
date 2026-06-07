## Issue 10 — lint pass tools/ai

### statusline.bats has no diff

```
statusline.bats is absent from the diff. The spec lists 6 files; only 5 bats files were touched.
```

**Problem:** Spec reviewer flagged that `statusline.bats` had no changes in the diff.
**Reason skipped:** `statusline.bats` was already lint-clean before this session — `bats-lint` returned `[]` on it in the initial scan. No changes were needed, so no diff was produced. All 6 files pass `bats-lint` as required.
