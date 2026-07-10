## Issue 01 — no-test-suffix ESLint rule

### Test location and approach diverge from spec

```
modules/lint/configs/eslint/__tests__/no-test-suffix.js  (RuleTester)
```

**Problem:** Spec mandates `modules/lint/lib/__tests__/` with `run()` integration pattern. Test lives in `configs/eslint/__tests__/` and uses `RuleTester`.

**Reason skipped:** User explicitly requested colocation of test files with their rules (one test file per rule, sibling of `rules/`), and asked to test at the lowest possible level rather than going through `run()`. Both decisions made during the session.
