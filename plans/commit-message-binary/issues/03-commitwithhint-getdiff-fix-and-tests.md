## TLDR

Fix `commitWithHint.getDiff()` to handle binary-only staged files, and add tests to cover the three staged-file scenarios.

## What to build

`commitWithHint.getDiff()` currently joins per-file diffs without trimming, so a whitespace-only result reaches the API. Apply the same pattern as `commitWithoutHint.getDiff()`: trim the joined diff, and if empty, return a fallback string listing the staged files (post-exclusion) as `"Binary files added:\n- file1\n- file2"`.

Then add a test file covering the same three scenarios as issue 02, with the addition that plan-noise files (state.json, GUIDANCE.md, review-log.md) are excluded from both the diff and the fallback list.

Mock `Gilmore` via `vi.mock('gilmore')`. Mock `getPlanDir` via `vi.mock('./getPlanDir.js')` to return a predictable plan directory path, so that the exclusion list is deterministic in tests.

## Behavioral Tests

**Binary-only staged files (plan-noise files present but excluded):**
- `getDiff()` returns `"Binary files added:\n- file.nes"` when all non-plan staged files produce empty diffs
- plan-noise files (state.json, GUIDANCE.md, review-log.md) do not appear in the fallback list

**Text files staged:**
- `getDiff()` returns the raw diff string when staged files produce non-empty diffs

**Mixed binary and text:**
- `getDiff()` returns only the text diff

## Acceptance criteria

- [ ] `commitWithHint.getDiff()` trims the joined diff before returning
- [ ] `commitWithHint.getDiff()` returns the binary file list fallback when diff is empty after trim
- [ ] Test file exists for `commitWithHint`
- [ ] Three scenarios tested
- [ ] Plan-noise exclusion verified in the binary-only test case
- [ ] All tests pass (`yarn run test`)
- [ ] Lint passes (`yarn run lint:fix`)
