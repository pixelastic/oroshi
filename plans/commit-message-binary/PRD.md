## Problem Statement

When only binary files are staged (e.g. NES ROMs, images), `git-commit-message` crashes with an API error. Binary files produce no unified diff output from `git diff --cached`, so the diff string passed to the Anthropic API is empty or whitespace-only — a payload the API rejects. The error message ("API error: 400") gives no indication of the real cause, making it look like a key or network problem.

The bug affects specifically the `commitWithHint` strategy (used in ralph worktrees with a `COMMIT_HINT.md`): it joins per-file diffs without trimming, so whitespace-only content reaches the API. The `commitWithoutHint` strategy already has a partial fix but lacks a test.

## Solution

Two complementary fixes:

1. **Both `getDiff()` strategies** detect a whitespace-only diff and fall back to a human-readable list of staged binary files, so the API always receives meaningful content.
2. **`callApi`** gains an early guard that errors out with a clear diagnostic message before touching the network if the diff is empty, regardless of which strategy produced it.

## User Stories

1. As a developer staging only binary files in a ralph worktree, I want `git-commit-message` to generate a commit message describing which binary files were added, so that I don't have to write it manually.
2. As a developer staging only binary files outside a ralph worktree, I want `git-commit-message` to generate a commit message describing which binary files were added, so that commits are consistent with text-file commits.
3. As a developer staging a mix of binary and text files, I want `git-commit-message` to generate a commit message based on the text diff only, so that binary files don't corrupt the diff content.
4. As a developer who accidentally calls `git-commit-message` with an empty diff, I want a clear error message explaining that the diff is empty rather than a cryptic API error, so that I can diagnose the problem immediately.
5. As a developer debugging `git-commit-message`, I want the empty-diff guard to fire before any network call, so that I am not misled into thinking the API key or network is at fault.

## Implementation Decisions

- **`commitWithHint.getDiff()`** is aligned with `commitWithoutHint.getDiff()`: the joined diff is trimmed, and if the result is empty, a fallback string listing the staged files (post-exclusion) is returned in the form `"Binary files added:\n- file1\n- file2"`.
- **Duplication is acceptable**: the binary fallback logic is small and symmetric. No shared helper is extracted.
- **`callApi`** checks `diff.trim()` before constructing the request body. If empty, it calls `consoleError` with an explicit message and exits with code 1.
- **Exit code 1** for the `callApi` guard: an empty diff reaching this point is a programming error upstream, not a normal "nothing to do" condition.
- **Plan-noise files** (state.json, GUIDANCE.md, review-log.md) excluded by `commitWithHint` are also excluded from the binary fallback list, since the same `cleanStagedFiles` array is reused.

## Testing Decisions

Good tests verify observable behavior from the outside — what the function returns given certain inputs — without asserting on internal implementation details such as which git commands were run.

**Modules with tests:**

- **`commitWithoutHint.getDiff()`** — three cases: binary-only staged files (fallback returned), text files (real diff returned), mixed binary + text (text diff returned).
- **`commitWithHint.getDiff()`** — same three cases, with plan-noise files present in staged list to confirm exclusion.
- **`callApi`** — three cases: empty diff (guard fires, exits 1), missing API key (existing behavior), non-200 API response (existing behavior).

**Mocking approach:** `Gilmore` is mocked via `vi.mock('gilmore')` — it is the direct external collaborator of both `getDiff()` implementations. `fetch` is mocked for `callApi` tests. No deeper collaborators (e.g. `getPlanDir`) are mocked; they either do not affect the tested behavior or fail gracefully in the test environment.

**Prior art:** `__tests__/getDeletedPlanName.js` — same repo, uses `vi.mock('gilmore')` with `Gilmore.mockReturnValue({ ... })` and `it.each` for multiple cases.

## Out of Scope

- Handling the case where no files are staged at all (empty `stagedFiles()` result) — this is caught earlier in the git workflow.
- Improving the binary fallback message format (e.g. adding file sizes or MIME types).
- Adding tests for `getCommitHint`, `getPlanDir`, or `git-commit-message.js` entry point.
- Extracting a shared `getDiff` utility between the two strategies.
