## TLDR

Create generic `test-path` autoload function that dispatches to the correct language-specific `*-test-path`.

## What to build

Create `autoload/misc/test-path` that:

- Input: path to any source file
- Early return 1 for `.bats` files (no test for a test file)
- If `is-js` matches, delegate to `js-test-path`
- If `is-python` matches, delegate to `python-test-path`
- Fallback: delegate to `bats-test-path` (covers ZSH autoload, shell scripts, etc.)
- Same contract as individual `*-test-path` functions: echo test path on success, return 1 on failure

## Behavioral Tests

**JS source file with existing test:**
- dispatches to js-test-path, returns correct path

**Python source file with existing test:**
- dispatches to python-test-path, returns correct path

**ZSH/shell file with existing bats test:**
- falls back to bats-test-path, returns correct path

**.bats file input:**
- returns exit code 1, no output (early return)

**Unrecognized file type (e.g. .md, .json):**
- falls through to bats-test-path fallback, returns exit code 1 if no matching .bats test

**No argument provided:**
- returns exit code 1, no output

## Acceptance criteria

- [ ] `test-path` created in `autoload/misc/`
- [ ] Correctly dispatches JS → js-test-path
- [ ] Correctly dispatches Python → python-test-path
- [ ] Falls back to bats-test-path for shell/ZSH/unknown
- [ ] Early returns 1 for .bats files
- [ ] All behavioral tests pass
