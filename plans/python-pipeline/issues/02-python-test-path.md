## TLDR

New script that resolves a Python source file to its pytest test file path.

## What to build

Create `scripts/bin/python/python-test-path`.

Given a file path:
- If the file is already inside a `__tests__/` directory AND its filename starts with `test_` AND has a `.py` extension → return it as-is (after confirming it exists).
- Otherwise → look for `__tests__/test_{basename_without_extension}.py` in the same directory as the input file. Return it if it exists, exit non-zero if not.
- Exit non-zero for missing or empty input.

Follow the `bats-test-path` pattern (same structure, same exit conventions).

## Behavioral Tests

**Already a test file**
- Input is `__tests__/test_foo.py` → returned as-is

**Source file with matching test**
- Input is `foo.py` with a sibling `__tests__/test_foo.py` → returns the test path

**No matching test**
- Input is `foo.py` with no `__tests__/test_foo.py` → exits non-zero, empty output

**Invalid input**
- No argument provided → exits non-zero

## Acceptance criteria

- [ ] Already-a-test file is returned directly
- [ ] Source file resolves to `__tests__/test_{basename}.py`
- [ ] Missing test → exits non-zero
- [ ] No argument → exits non-zero
- [ ] BATS tests pass (`bats scripts/bin/python/__tests__/python-test-path.bats`)
- [ ] `zsh-lint` passes on the new script
