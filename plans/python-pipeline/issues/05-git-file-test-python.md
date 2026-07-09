## TLDR

Add a Python branch to `git-file-test` so dirty Python source files trigger their pytest tests.

## What to build

Modify `tools/term/zsh/config/functions/autoload/git/file/git-file-test`:

1. Add a `pythonPaths=()` array.
2. In the file-classification loop, detect Python files using `is-python`.
3. For each detected Python file, call `python-test-path` to resolve the test path. Skip silently if no test is found.
4. After the loop, if `pythonPaths` is non-empty, call `python-test "${pythonPaths[@]}"`.

Use absolute paths throughout (consistent with how `python-test` resolves its arguments).

## Behavioral Tests

**Python source file with a test**
- When dirty files include a `.py` source file that has a matching test, `python-test` is called with the resolved test path

**Python source file without a test**
- When dirty files include a `.py` source file with no matching test, `python-test` is not called and the function exits 0

## Acceptance criteria

- [ ] Dirty `.py` source files with a matching test → `python-test` is called
- [ ] Dirty `.py` source files with no matching test → silently skipped
- [ ] Non-Python dirty files are unaffected
- [ ] BATS tests pass (`bats tools/term/zsh/config/functions/autoload/git/file/__tests__/git-file-test.bats`)
- [ ] `zsh-lint` passes on the modified function
