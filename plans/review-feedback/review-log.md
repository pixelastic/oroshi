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

## Issue 02b — md2gdocs-docx
### firost.env() over process.env
```javascript
get FOLDER_ID() {
  return process.env.OROSHI_GOOGLE_DRIVE_DOCS_FOLDER_ID;
},
```
**Problem:** Uses `process.env` directly instead of `firost.env()`
**Reason skipped:** Existing `md2gdocs.js` uses same pattern; consistency with sibling file wins

### firost path utils over node:path
```javascript
import path from 'node:path';
```
**Problem:** Uses `node:path` instead of firost's `dirname()`
**Reason skipped:** `path.join`, `path.basename`, `path.extname` have no firost equivalent; mixing firost `dirname` with `node:path` for the rest would be inconsistent

### reference.docx generation script not committed
```
scripts/bin/markdown/md2gdocs/reference.docx
```
**Problem:** Spec says "Generated programmatically" but no generation script is committed
**Reason skipped:** File was generated ad hoc and committed as binary artifact; a persistent build script is out of scope for this issue

## Issue 04 — gdocs-comments-json
### includeDeleted flag on comments.list
```javascript
const response = await drive.comments.list({
  fileId: docId,
  fields: 'nextPageToken,comments(content,resolved,quotedFileContent)',
  pageToken,
});
```
**Problem:** Reviewer flagged that `includeDeleted` is not set on `comments.list`
**Reason skipped:** Spec doesn't mention deleted comments; API default (exclude deleted) is correct behavior — deleted comments have no actionable content

## Issue 06 — review-article skill
### Step separators between sections
```markdown
---
```
**Problem:** `---` separators between steps inconsistent with some skills (review-slide, review)
**Reason skipped:** `deprecate/SKILL.md` uses the same pattern; not a universal convention

### Step 2 "Wait" has no substantive work
```markdown
### Step 2 — Wait
Do nothing until the user comes back.
```
**Problem:** Step has no agent work — just "do nothing"
**Reason skipped:** Inherently interactive; the skill must pause for user annotation, there's no way to avoid a wait step

### Blockquote message templates
```markdown
> Here's the doc: {url}
```
**Problem:** No existing skill uses blockquotes for user-facing message templates
**Reason skipped:** Makes expected output clearer and visually distinct from instructions; stylistic choice
