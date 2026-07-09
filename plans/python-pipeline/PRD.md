## Problem Statement

Python files are invisible to the dirty-file lint/test workflow (`vfl`/`vft`) and to the pre-commit lint-staged hook. When a developer edits a `.py` file, no linting or testing runs automatically — violations accumulate and tests go unrun until a manual invocation.

## Solution

Wire Python into every stage of the existing lint/test pipeline, matching how ZSH and JS are already handled:

- `vfl` (lint dirty files) picks up `.py` files, auto-fixes them with ruff, and reports remaining violations.
- `vft` (test dirty files) resolves the test file for any dirty `.py` source file and runs it with pytest.
- The pre-commit lint-staged hook lints and tests staged `.py` files the same way.

Two new helper primitives (`is-python`, `python-test-path`) encapsulate Python detection and test path resolution, keeping the pipeline functions clean and the helpers independently testable.

As part of this work, `zsh-lint` calls are also upgraded to pass `--fix` (already supported by `zsh-lint`) in both the dirty-file linter and the lint-staged hook, so ZSH auto-fix behaviour becomes consistent with Python.

## User Stories

1. As a developer, I want `vfl` to lint dirty Python files with ruff auto-fix so that fixable violations are corrected automatically and remaining ones are reported.
2. As a developer, I want `vft` to find and run the pytest test file for any dirty Python source file so that I get test feedback without manually locating the test.
3. As a developer, I want `vft` to silently skip Python files that have no associated test so that the workflow is noise-free.
4. As a developer, I want the pre-commit hook to lint staged `.py` files with `python-lint --fix` so that committed code is always ruff-clean.
5. As a developer, I want the pre-commit hook to run the pytest test for each staged `.py` file so that broken tests block the commit.
6. As a developer, I want `python-lint` to accept multiple file arguments so that batch invocations from the pipeline work without a wrapper loop.
7. As a developer, I want `is-python` to detect Python files by `.py` extension or `#!/usr/bin/env python3` / `#!/usr/bin/env python` shebang so that extension-less Python scripts are also caught.
8. As a developer, I want `python-test-path` to return a test file path directly when the input is already a `test_*.py` file so that test files are not double-resolved.
9. As a developer, I want `python-test-path` to look for `__tests__/test_{basename}.py` relative to the source file so that the pytest naming convention is respected.
10. As a developer, I want `vfl` to auto-fix ZSH files (not just report) so that `vfl` Python and ZSH behaviour are consistent.
11. As a developer, I want the pre-commit hook to auto-fix staged ZSH files so that the commit hook and `vfl` are consistent.

## Implementation Decisions

- **`is-python`** follows the `is-js` pattern: `.py` extension is the primary check; for extension-less files, the first line is inspected for a `#!/usr/bin/env python3` or `#!/usr/bin/env python` shebang. Symlinks and non-regular files return false.

- **`python-test-path`** follows the `bats-test-path` pattern: if the input filename matches `test_*.py`, it is returned directly (after confirming it exists); otherwise the script looks for `__tests__/test_{basename_without_extension}.py` in the same directory as the source file.

- **`python-lint` multi-file support**: the script is extended to loop over all positional arguments internally. Each file is processed in sequence with the same ruff format + check + report logic. The `--fix` and `--json` flags apply to all files in the batch.

- **`git-file-lint` Python branch**: a `python-files` key is added to the results associative array. Detection uses `is-python`. The linter is called as `python-lint --fix <files>`. Output is plain text (like the existing JS branch), handled by a `displayPythonLintErrors` helper. The existing ZSH branch is updated to pass `--fix` to `zsh-lint`.

- **`git-file-test` Python branch**: a `pythonPaths` array accumulates test paths resolved by `python-test-path`. At the end, `python-test` is called with all resolved paths (absolute). Files with no matching test are silently skipped.

- **Lint-staged yarn wrappers**: `scripts/yarn/lint-python` mirrors `lint-zsh` (filters by `is-python`, calls `python-lint --fix`). `scripts/yarn/test-python` mirrors `test-bats` (resolves paths via `python-test-path`, deduplicates, calls `python-test`). Both are registered in `package.json` as `lint:python` and `test:python`.

- **`lintstaged.config.js`**: a `**/*.py` entry is added calling `['yarn run lint:python', 'yarn run test:python']`.

- **`scripts/yarn/lint-zsh`**: `--fix` is added to the `zsh-lint` call.

## Testing Decisions

Good tests verify external behaviour through the public interface — they do not inspect internal state or implementation details. For shell helpers, this means calling the binary and asserting exit code and stdout, never inspecting how the detection is implemented.

**Modules with BATS tests:**

- `is-python` — test matrix: `.py` extension, `#!/usr/bin/env python3` shebang, `#!/usr/bin/env python` shebang, extension-less file with no shebang (should return false), symlink (false), directory (false), non-existent file (false), file with a different extension (false). Prior art: `is-js` tests.
- `python-test-path` — test matrix: input is already `test_*.py` (returns it), source file with existing `__tests__/test_{basename}.py` (returns path), source file with no matching test (returns empty / exits non-zero), non-existent input (exits non-zero). Prior art: `bats-test-path` tests.

**Modules without tests:** `git-file-lint`, `git-file-test`, yarn wrappers, `lintstaged.config.js`, `package.json` — these are thin wiring layers with no logic of their own.

## Out of Scope

- Adding `--fix` support to `bats-lint` (no auto-fix tool exists for BATS).
- Python type-checking (mypy or pyright) in the pipeline.
- Test discovery for non-`__tests__/test_*.py` pytest layouts.
- Running the full pytest suite (only per-file test resolution is in scope).
- Changes to how `python-test` itself works.

## Further Notes

The `__tests__/test_{basename}.py` convention is confirmed by the existing test file in the kitty config module. The `python-test-path` script should be robust to missing test files — returning empty output and exiting non-zero — so callers can safely skip files with no tests.
