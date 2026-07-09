## TLDR

Add a Python branch to `git-file-lint` and upgrade ZSH linting to auto-fix.

## What to build

Modify `tools/term/zsh/config/functions/autoload/git/file/git-file-lint`:

1. Add `python-files` to the `results` associative array.
2. In the file-classification loop, detect Python files using `is-python` and accumulate them under `python-files`.
3. After the loop, call `python-lint --fix` on the accumulated Python files and display output via a new `displayPythonLintErrors` helper (plain text, same shape as `displayJsLintErrors`).
4. Change the existing `zsh-lint` call to pass `--fix`.

## Behavioral Tests

**Python files linted**
- When dirty files include a `.py` file, `python-lint` is called on it

**ZSH --fix**
- When dirty files include a `.zsh` file, `zsh-lint --fix` is called (not `zsh-lint`)

## Acceptance criteria

- [ ] Dirty `.py` files are detected and passed to `python-lint --fix`
- [ ] `displayPythonLintErrors` prints plain-text output under a `── Python ──` header
- [ ] `zsh-lint` is now called with `--fix`
- [ ] Non-Python, non-ZSH files are unaffected
- [ ] BATS tests pass (`bats tools/term/zsh/config/functions/autoload/git/file/__tests__/git-file-lint.bats`)
- [ ] `zsh-lint` passes on the modified function
