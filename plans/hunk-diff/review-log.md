## Issue 01 — Classification
### Test filename mismatch with spec
```
__tests__/classify.js  (actual)
__tests__/classify.test.js  (spec says)
```
**Problem:** Spec says `classify.test.js` but file was created as `classify.js`
**Reason skipped:** js-writer convention says test files use plain module name (`__tests__/basename.js`), no `.test.` suffix. Convention overrides spec typo.
