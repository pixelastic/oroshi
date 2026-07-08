## TLDR

Add an early guard in `callApi` that exits with a clear error before touching the network if the diff is empty or whitespace-only.

## What to build

Before constructing the API request body, `callApi` checks whether the diff (after trimming) is empty. If so, it calls `consoleError` with a message explaining the problem (e.g. "Empty diff: nothing to send to the API.") and exits with code 1. No network call is made.

Add a test file for `callApi` covering this new guard as well as the two existing early-exit cases (missing API key, non-200 API response).

## Behavioral Tests

**Empty diff guard:**
- exits with code 1 when diff is an empty string
- exits with code 1 when diff is whitespace-only
- prints a clear diagnostic message mentioning "empty diff"

**Missing API key (existing behavior, new test):**
- exits with code 1 when `ANTHROPIC_API_KEY` is not set

**API error response (existing behavior, new test):**
- exits with code 1 when the API returns a non-200 status

## Acceptance criteria

- [ ] `callApi` exits 1 with a descriptive error message when diff is empty or whitespace-only
- [ ] No HTTP request is made when the diff is empty
- [ ] Test file covers the three scenarios above
- [ ] All tests pass (`yarn run test`)
- [ ] Lint passes (`yarn run lint:fix`)
