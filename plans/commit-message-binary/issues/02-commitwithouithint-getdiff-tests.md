## TLDR

Add tests for `commitWithoutHint.getDiff()` to confirm its existing binary fallback behavior.

## What to build

No production code changes. Write a test file for `commitWithoutHint.getDiff()` covering three scenarios: binary-only staged files, text files, and a mix. The binary fallback (`"Binary files added:\n- file"`) is already implemented — these tests confirm and lock in that behavior.

Mock `Gilmore` via `vi.mock('gilmore')`. The mock controls what `stagedFiles()` returns (the file list) and what `run('diff --cached -- ...')` returns per file (empty string for binary, diff text for text files).

Prior art: `__tests__/getDeletedPlanName.js` in the same directory — uses `vi.mock('gilmore')` with `Gilmore.mockReturnValue({ ... })` and `it.each` for multiple cases.

## Behavioral Tests

**Binary-only staged files:**
- `getDiff()` returns `"Binary files added:\n- file.nes"` when all staged files produce empty diffs

**Text files staged:**
- `getDiff()` returns the raw diff string when staged files produce non-empty diffs

**Mixed binary and text:**
- `getDiff()` returns only the text diff (binary files contribute empty strings, trimmed away)

## Acceptance criteria

- [ ] Test file exists for `commitWithoutHint`
- [ ] Three scenarios tested with `it.each` or equivalent
- [ ] `yarn.lock` is excluded from the staged file list in tests (confirm via a test that includes it)
- [ ] All tests pass (`yarn run test`)
- [ ] Lint passes (`yarn run lint:fix`)
