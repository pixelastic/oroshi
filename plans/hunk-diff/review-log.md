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

## Issue 03 — Extension wiring
### export default instead of named export
```javascript
export default function addedOnly(hunk) {
```
**Problem:** js-writer convention says "DO NOT use `export default`, always named exports"
**Reason skipped:** hunkdiff API requires `ExtensionFactory` as default export (`/** Default export every extension entry file must provide. */`). External API constraint overrides internal convention.

### Standalone it blocks could be it.each
```javascript
it('uses added tone for + marker in fallback spans', () => {
  expect(layout.rows[1].spans[0]).toEqual({ text: '+ ', tone: 'added' });
});
it('uses muted tone for line number', () => {
  expect(layout.rows[1].spans[1]).toEqual({ text: '2 ', tone: 'muted' });
});
```
**Problem:** Several standalone `it` blocks with similar assertion shape could be consolidated into `it.each`
**Reason skipped:** Each test checks a different conceptual property (marker tone, line number tone, content span, context marker) with different row/span indices. Consolidating into `it.each` would hurt readability without meaningful benefit.
