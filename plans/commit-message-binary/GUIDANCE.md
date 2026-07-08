## Guidance

**Goal:** Fix `git-commit-message` crashing with an API error when only binary files are staged.

**Test command:** `yarn run test <filepath>`
**Lint command:** `yarn run lint:fix <filepath>`

**Key files (relative to repo root):**
- `scripts/bin/git/commit/git-commit-message/callApi.js` — API wrapper; receives `{ prompt, diff }`
- `scripts/bin/git/commit/git-commit-message/commitWithoutHint.js` — strategy for repos without COMMIT_HINT.md; binary fallback already implemented
- `scripts/bin/git/commit/git-commit-message/commitWithHint.js` — strategy for ralph worktrees; missing binary fallback
- `scripts/bin/git/commit/git-commit-message/__tests__/` — test directory; prior art in `getDeletedPlanName.js`

**Mocking conventions:**
- `vi.mock('gilmore')` + `Gilmore.mockReturnValue({ stagedFiles: vi.fn(), run: vi.fn() })` — controls staged file list and per-file diff output
- `vi.mock('./getPlanDir.js')` + named export mock — controls which files are excluded in `commitWithHint`
- `fetch` is a global; mock with `vi.stubGlobal('fetch', vi.fn())`

**Binary file behavior:** `git diff --cached -- binaryfile` returns empty stdout. `git diff --cached --name-only` returns binary filenames. So `stagedFiles()` lists them; `run('diff --cached -- ...')` returns `''` for them.

**Fallback format:** `"Binary files added:\n- file1\n- file2"` (same in both strategies).

**Exit code:** `process.exit(1)` for all error cases in `callApi`.

## Discoveries

### Issue 01 — callApi empty diff guard
- `process.exit` must be mocked to throw (not no-op) — otherwise code continues past the guard and `fetch` gets called, breaking the "no network call" assertion.
- `vi.stubGlobal('fetch', vi.fn())` in `beforeEach` doesn't need `afterEach` cleanup; vitest isolates per file and `beforeEach` re-stubs fresh each test.
- Empty catch blocks (no binding, just a comment) are the right pattern when suppressing a thrown mock error — `let actual = null` is only for when you assert on the error itself.
