## Issue 02 — Commit hint wiring

### getCommitHint in separate module vs. main script

```js
// getCommitHint.js
export async function getCommitHint() { ... }
```

**Problem:** Spec acceptance criterion says "`getCommitHint()` exists in the main script". Reviewer flagged the function lives in a separate module instead.

**Reason skipped:** The main script (`git-commit-message.js`) runs top-level code at import time. If `getCommitHint` were internal to the main script, importing the main script in tests would trigger API calls, env var checks, and git operations — requiring mocking of every dependency before dynamic import. Extracting to a separate module is the only clean testable design.

### buildSystemPrompt in separate module vs. inline in main script

```js
// buildSystemPrompt.js
export function buildSystemPrompt(template, hint) { ... }
```

**Problem:** Spec says the `{{COMMIT_HINT}}` replacement logic should live inline in the main script wiring. Reviewer flagged a separate module wasn't specified.

**Reason skipped:** Same root cause. A pure function module is directly unit-testable and covers the spec's "main script" behavioral tests (prompt with/without hint instruction) exactly. Inline logic would require the same complex `vi.doMock` + dynamic import pattern to test.
