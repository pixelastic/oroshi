## Issue 01 — Classification
### Test filename mismatch with spec
```
__tests__/classify.js  (actual)
__tests__/classify.test.js  (spec says)
```
**Problem:** Spec says `classify.test.js` but file was created as `classify.js`
**Reason skipped:** js-writer convention says test files use plain module name (`__tests__/basename.js`), no `.test.` suffix. Convention overrides spec typo.

## Issue 02 — Layout
### Test file naming
```
__tests__/layout.js  (actual)
__tests__/layout.test.js  (spec says)
```
**Problem:** Spec says test file should be `layout.test.js`
**Reason skipped:** js-writer skill mandates plain module name without `.test.`/`.spec.` suffix; existing test (`classify.js`) follows same convention. Coding standard overrides spec typo.
