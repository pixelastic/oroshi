## TLDR

Create `js-test-path` autoload function that resolves a JS source file to its test file path.

## What to build

Create `autoload/_languages/javascript/js-test-path` following the same contract as `bats-test-path` and `python-test-path`:

- Input: path to a JS file
- If no argument provided, return 1
- If the file is already a JS test (parent dir is `__tests__`), return it directly (or return 1 if it doesn't exist)
- Otherwise, build test path as `dir/__tests__/basename.js` (same basename, same extension)
- If the test file doesn't exist on disk, return 1
- Otherwise, echo the test path

## Behavioral Tests

**Valid source file with existing test:**
- returns the path to the test file in `__tests__/`

**Input is already a test file:**
- returns the file path directly

**Source file with no matching test:**
- returns exit code 1, no output

**No argument provided:**
- returns exit code 1, no output

**Non-JS file:**
- returns exit code 1, no output

## Acceptance criteria

- [ ] `js-test-path` created in `_languages/javascript/`
- [ ] Follows autoload conventions (setopt local_options err_return, return not exit)
- [ ] All behavioral tests pass
- [ ] Contract matches `bats-test-path` and `python-test-path`
