# Review Log

## Session: callApi empty-diff guard

### Skipped — false positive
**Standards: JSDoc missing on `callApi`** — JSDoc block was already present on the function (lines 2–8 of callApi.js); reviewer did not see it.

### Skipped — consistent with existing style
**Spec: message case mismatch** — spec says "mentioning 'empty diff'" (lowercase). Implementation uses `'Empty diff: ...'` (capital E), consistent with `'ANTHROPIC_API_KEY not set.\n'` in the same file. No change made.

**Spec: trailing `\n` in `consoleError` call** — `'Empty diff: nothing to send to the API.\n'` follows the same pattern as the existing `'ANTHROPIC_API_KEY not set.\n'` call in the same function. Pre-existing style, kept consistent.
