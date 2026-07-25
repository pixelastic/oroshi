## TLDR

Extract the duplicated `getDiff()` logic from both strategies into a shared `getDiff` module.

## What to build

Create a `getDiff.js` module next to the strategy files. It exports a single async function `getDiff(excludedFiles)` that:

1. Calls `repo.stagedFilesWithStatus()` to get `[{ name, status, from?, similarity? }]`
2. Filters out files matching `excludedFiles`
3. Diffs remaining non-rename files with `repo.run('diff --cached -M -- <filepath>')`
4. Joins diffs, applies the binary fallback for empty diffs (same logic as today)
5. Returns the final diff string

Both `commitWithHint.js` and `commitWithoutHint.js` replace their `getDiff()` methods with a call to this shared helper, each passing their own exclusion list.

At this stage, rename-only files are NOT handled specially — they go through the normal diff path. The rename fallback is added in issue 02.

## Scaffolding Tests

- `commitWithHint.getDiff()` delegates to the shared `getDiff` module
- `commitWithoutHint.getDiff()` delegates to the shared `getDiff` module

## Acceptance criteria

- [ ] `getDiff.js` exists and exports `getDiff(excludedFiles)`
- [ ] `commitWithHint.getDiff()` calls `getDiff` with plan-noise exclusions
- [ ] `commitWithoutHint.getDiff()` calls `getDiff` with `['yarn.lock']`
- [ ] All existing tests pass without modification (behavior unchanged)
