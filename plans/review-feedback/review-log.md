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
