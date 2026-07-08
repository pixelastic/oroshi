## Problem Statement

When refactoring existing Python code (specifically the kitty tabbar modules), there is no established workflow to guide an agent safely: no linter is enforced, no test runner is defined, and no skill exists to encode conventions. The developer does not read or write Python and cannot manually review agent output for correctness. Without a structured write → test → lint loop, regressions go undetected and the agent has no guardrails.

A secondary problem: the lint/fix pattern is inconsistent across languages. ZSH has `zsh-lint` (check only) and `zshfix` (format only) as separate commands. Python has `python-lint` (check only) and `python-fix` (format only). JavaScript uses `yarn lint:fix` — one command that fixes what it can and reports the rest. Agents on ZSH and Python must run two commands and mentally combine their output, while JS agents run one.

## Solution

Create a `python-writer` skill that gives agents a structured workflow for writing Python: place the file, write a failing test, implement the code, run `python-lint --fix`. Also create the `python-test` bin script and install pytest. Update `python-lint` and `zsh-lint` to accept a `--fix` flag, unifying the lint/fix pattern across all three languages. Update `zsh-writer` to use `zsh-lint --fix` in its Step 4.

## User Stories

1. As an agent using python-writer, I want a step-by-step workflow, so that I produce consistent Python without requiring manual review.
2. As an agent using python-writer, I want to know where to place a new Python file, so that it lands in the right directory.
3. As an agent using python-writer, I want to write a failing test first, so that the implementation is verified from the start.
4. As an agent using python-writer, I want a single lint command that fixes what it can and reports the rest, so that I do not need to run two separate commands.
5. As an agent using python-writer, I want explicit style guidance on return early, so that I avoid unnecessary nesting without being given an opinion on everything.
6. As an agent using python-writer, I want a reference for how to structure test files, so that I follow the repo convention without guessing.
7. As an agent using python-writer, I want to know how to mock unavailable imports (e.g. a runtime-only API), so that tests can run outside of that runtime environment.
8. As a developer, I want `python-lint --fix` to auto-correct everything fixable and show only what requires manual attention, so that I never waste time on auto-fixable violations.
9. As a developer, I want `zsh-lint --fix` to behave the same way as `python-lint --fix`, so that the pattern is uniform across languages.
10. As a developer, I want `python-test <filepath>` to run pytest with the correct PYTHONPATH automatically, so that I do not need to configure the environment manually each time.
11. As a developer, I want pytest installed via the standard language install script pattern, so that setup is reproducible and documented alongside other language tools.
12. As a developer, I want CLAUDE.md to distinguish between "do not propose Python for new scripts" and "use python-writer when editing existing Python", so that agents are not blocked from working on existing Python code.
13. As an agent using zsh-writer, I want Step 4 to use `zsh-lint --fix` instead of `zsh-lint`, so that the workflow matches the new unified pattern.

## Implementation Decisions

### `python-lint --fix` flag
`python-lint` gains a `--fix` flag. When passed, it runs ruff format (auto-format) then `ruff check --fix` (auto-fix lint violations), then runs `ruff check` to display remaining violations that require manual attention. Without `--fix`, behavior is unchanged (check only).

### `zsh-lint --fix` flag
`zsh-lint` gains a `--fix` flag. When passed, it calls `zshfix` on the file first (auto-format via shfmt/beautysh), then runs the normal lint check to display remaining violations. `zshfix` stays as the internal formatting implementation; `zsh-lint --fix` is the public interface agents call.

### `python-test` bin script
A new script in `scripts/bin/python/python-test` wrapping pytest. It receives a filepath and delegates directly to `pytest`. PYTHONPATH resolution is handled by `pyproject.toml` in the project root (see below), not by the script itself.

### `pyproject.toml` in the kitty config directory
A `pyproject.toml` lives at the root of the kitty Python project (the `config/` directory containing `tab_bar.py`). It configures pytest with `pythonpath = ["."]` so that `from tab_bar_modules.xxx import ...` resolves correctly regardless of where pytest is invoked from.

### `pytest` install
A new install script at `tools/_languages/python/pytest/install`, mirroring the existing `tools/_languages/python/ruff/install` pattern. Uses `pipx install pytest` or equivalent.

### `conftest.py` placement
The shared `conftest.py` that stubs runtime-only imports lives at the `config/` level (the same directory as `pyproject.toml`), making it available to all test subdirectories under `config/`. Per-test-directory `conftest.py` files may be added for domain-specific fixtures.

### Test location convention
Python tests follow the same `__tests__/` convention as ZSH and JavaScript tests: a `__tests__/` directory sibling to the module being tested, containing `test_<module>.py` files.

### `python-writer` skill structure
Mirrors `zsh-writer`: a `SKILL.md` with four numbered steps (place, failing test, write code, lint) and two reference files:
- `references/testing.md` — generic pytest conventions: test file naming, conftest.py purpose, how to stub unavailable imports via `sys.modules`, `@pytest.mark.parametrize` for multi-case tests.
- `references/style.md` — return early pattern only; all other style delegated to ruff.

### CLAUDE.md update
The current rule `NEVER: Never suggest to write a script in python` is split into two:
- `NEVER: Never propose Python as the implementation language for a new script — prefer ZSH or JavaScript.`
- `DO: When Python is explicitly requested or when modifying existing Python files, use python-writer.`

### `zsh-writer` Step 4 update
Step 4 changes from `zsh-lint <file>` to `zsh-lint --fix <file>`, aligning with the new unified pattern.

## Testing Decisions

Good tests verify external behavior, not implementation details. A test for `python-lint --fix` does not inspect which ruff subcommands were called — it passes a file with known violations, runs the command, and asserts the file was modified and the exit code reflects remaining violations.

### Modules with bats tests
- **`python-lint --fix`**: new bats test cases — given a file with auto-fixable violations, assert the file is corrected in place; given a file with unfixable violations, assert non-zero exit and error output.
- **`python-test`**: new bats test — given a valid test file, assert exit 0; given a failing test, assert non-zero exit.
- **`zsh-lint --fix`**: new bats test cases added to the existing `zsh-lint.bats` — given a file with fixable formatting, assert the file is reformatted; lint violations that survive auto-fix are still reported.

### Modules without tests
- `python-writer` SKILL.md and reference files — declarative documents, no test framework applies.
- `pyproject.toml` — configuration artifact, verified by running `python-test`.
- `tools/_languages/python/pytest/install` — install script, not testable in CI without a clean environment.
- CLAUDE.md — declarative instruction, no test applies.

## Out of Scope

- Type checking (mypy, pyright) — not installed, not needed for the current Python surface area.
- A `js-lint --fix` flag — JavaScript already uses `yarn lint:fix`; no change needed.
- Kitty-specific test fixtures (mock Screen, tabState setup) — these belong in the kitty plan issues, not in the generic python-writer skill.
- Removing or replacing `zshfix` — it stays as the internal implementation called by `zsh-lint --fix`.
- Adding Python support to `git-file-lint` or other repo-wide lint orchestration — out of scope for now.

## Further Notes

The `--fix` flag unification (`zsh-lint --fix`, `python-lint --fix`, `yarn lint:fix`) establishes a pattern that future language writers can follow without a separate design decision.

The `pyproject.toml` is scoped to the kitty config directory, not the oroshi root. If Python is added elsewhere in the repo in the future, each project gets its own `pyproject.toml`.
