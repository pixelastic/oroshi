## TLDR

Create `python-test` bin script, pytest install script, and `pyproject.toml` for the kitty config.

## What to build

### `tools/_languages/python/pytest/install`

New install script mirroring `tools/_languages/python/ruff/install`. Installs pytest via pipx (or pip --user if pipx is unavailable for pytest). Follow the exact same pattern as the ruff install script.

### `tools/term/kitty/config/pyproject.toml`

Minimal pytest configuration:
- `pythonpath = ["."]` so that `from tab_bar_modules.xxx import ...` resolves when pytest is invoked from any directory
- `testpaths = ["tab_bar_modules/__tests__"]` as the default test discovery path

### `scripts/bin/python/python-test`

New bin script wrapping pytest. Takes a filepath or directory as argument and delegates to `pytest`. PYTHONPATH resolution is handled by `pyproject.toml`, not by the script. Follow the header/usage comment conventions of `python-lint`.

Add a bats test file at `scripts/bin/python/__tests__/python-test.bats`.

## Behavioral Tests

**When passed a test file with passing tests:**
- Exit 0

**When passed a test file with failing tests:**
- Exit non-zero
- pytest output visible

**When passed a directory:**
- Runs all tests discovered in that directory

## Acceptance criteria

- [ ] `tools/_languages/python/pytest/install` exists and installs pytest
- [ ] `tools/term/kitty/config/pyproject.toml` exists with `pythonpath = ["."]`
- [ ] `python-test <filepath>` runs pytest on that file
- [ ] `python-test <dir>` runs pytest on that directory
- [ ] Exit code matches pytest exit code
- [ ] Bats tests cover passing and failing test file scenarios
- [ ] `python-test` follows the same header/usage comment style as `python-lint`
