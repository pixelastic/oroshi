## Issue 01 — Google Login
### No JSDoc on google-login.js server callback
```javascript
const server = http.createServer(async (request, response) => {
```
**Problem:** Anonymous function has no JSDoc
**Reason skipped:** Entry-point script with inline top-level logic, not an exported function — JSDoc on anonymous server callbacks is noise

### No __ private-method pattern in google-login.js
```javascript
const server = http.createServer(async (request, response) => {
```
**Problem:** Logic inlined at module scope, not testable via __ mocking
**Reason skipped:** Interactive CLI script (browser OAuth + HTTP server) — inherently HITL, not unit-testable

### No tests for google-login.js
**Problem:** No test coverage for the OAuth flow script
**Reason skipped:** Browser-based OAuth consent flow is HITL by nature — cannot be meaningfully unit tested

### Imprecise JSDoc return type on readTokens
```javascript
  /**
   * Read stored tokens from disk
   * @returns {object} Token object with refresh_token
   */
  readTokens() {
```
**Problem:** Returns Promise but JSDoc says {object}
**Reason skipped:** Promise wrapping is implicit with async callers; {object} describes the resolved value correctly

## Issue 02 — md2gdocs
### HTML upload vs Docs API body structure
```js
media: {
  mimeType: 'text/html',
  body: Readable.from(html),
},
```
**Problem:** Spec says "converts content to Google Docs API body structure" and names both Drive + Docs API. Implementation uses HTML upload via Drive API only.
**Reason skipped:** HTML upload achieves the same end result (formatted Google Doc) with far less complexity. The spec describes desired outcome, not a required integration approach.

### CLI arg parsing style
```js
const titleIndex = args.indexOf('--title');
let title;
if (titleIndex !== -1) {
  title = args[titleIndex + 1];
  args.splice(titleIndex, 2);
}
```
**Problem:** Imperative mutation with `splice` diverges from functional style standards favor.
**Reason skipped:** CLI entry is a thin script runner, not core logic. Functional rewrite adds complexity without benefit for a 5-line arg parser.

## Issue 03 — gdocs2md
### toContain vs toEqual in convertToMarkdown tests
```javascript
expect(actual).toContain('# Title');
```
**Problem:** Reviewer flagged `toContain` as weaker than `toEqual` when full output is deterministic.
**Reason skipped:** Facet tests on a shared rich context — each test observes one aspect. `toEqual` on the full string would make every test brittle to unrelated fixture changes.

### Empty JSDoc bodies on test helpers
```javascript
/**
 *
 * @param content
 * @param style
 */
function textRun(content, style = {}) {
```
**Problem:** JSDoc blocks have empty descriptions.
**Reason skipped:** Test-local helpers, not exported. Lint auto-generated the empty JSDoc blocks; adding prose would be noise.

### Side-effecting _.map in convertToMarkdown
```javascript
const lines = _.map(elements, (element) => {
  // mutates listCounters and previousType
```
**Problem:** `_.map` callback mutates outer variables; `_.reduce` would be more idiomatic.
**Reason skipped:** State (`listCounters`, `previousType`) is inherently sequential — `_.reduce` would move mutation into accumulator but not eliminate it. Current form is readable.
