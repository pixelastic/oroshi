## Problem Statement

The `bats_run_zsh` function signature was changed: it now accepts a single complete zsh command string (`zsh -c "$1"`), replacing the old API that accepted a binary name as the first argument plus separate extra arguments. As a result, all existing `.bats` test files that pass extra arguments to `bats_run_zsh` are currently broken — arguments beyond `$1` are silently dropped. Additionally, the `CURRENT` variable convention (storing the script-under-test path in `setup()`) is being retired in favour of calling scripts directly by name inside the command string.

## Solution

Migrate all 155 `.bats` files across the repo to the new conventions:
- Remove the `CURRENT` variable from `setup()`
- Call scripts directly by name inside a single `bats_run_zsh` command string
- For files that source a `.zsh` file, introduce a `sourcePrefix` variable instead
- Eliminate generated temp-file wrappers that existed solely to work around the old API
- Delete the now-obsolete lint rule that enforced the `CURRENT` naming convention

Migration is done file by file, with `bats` run after each file to catch regressions immediately.

## User Stories

1. As a developer running the test suite, I want all `bats_run_zsh` calls to pass arguments correctly, so that tests reflect the real behaviour of the scripts under test.
2. As a developer writing a new bats test, I want to call the script under test by name directly in the command string, so that the test is readable without indirection through a `CURRENT` variable.
3. As a developer writing a new bats test for a sourced `.zsh` file, I want a canonical `sourcePrefix` variable, so that I have a clear pattern to follow for source-based tests.
4. As a developer running `bats-lint`, I want the obsolete `rule-current-script-var` removed, so that the linter does not enforce a convention that is no longer valid.
5. As a developer reading a test file, I want `setup()` to be absent when it has no content, so that there is no empty boilerplate to read through.
6. As a developer, I want temp-file wrappers eliminated, so that tests call the function under test directly without unnecessary indirection.
7. As a developer, I want arguments with special characters (spaces, apostrophes) properly quoted inside the command string, so that `zsh -c` receives them correctly.
8. As a developer, I want `bats` to pass on every migrated file before moving to the next, so that regressions are caught at the smallest possible scope.

## Implementation Decisions

### Module 1 — Lint rule deletion
- Delete `rule-current-script-var.zsh` from the bats-lint rules directory.
- Done first, before any file migration, so the linter does not fire on intermediate states.

### Module 2 — Direct invocation migration (~62 files)
- Applies to files where `CURRENT` holds a path of the form `$BATS_TEST_DIRNAME/../script-name` (no extension, not a temp file).
- The script name is extracted from the assignment and inlined into every `bats_run_zsh` call site:
  - `bats_run_zsh "$CURRENT"` → `bats_run_zsh "script-name"`
  - `bats_run_zsh "$CURRENT" arg1 arg2` → `bats_run_zsh "script-name arg1 arg2"`
  - `bats_run_zsh "$CURRENT" ... <<< "$var"` → `bats_run_zsh "script-name ..." <<< "$var"` (heredoc redirect stays outside the string)
- The `CURRENT=` line is removed from `setup()`.
- If `setup()` becomes empty after removal, the entire `setup()` block is deleted.
- Quoting inside the merged string follows these rules:
  - Arguments already in single quotes stay as-is.
  - Arguments with spaces are wrapped in single quotes.
  - Arguments containing an apostrophe use the `'text d'\''apostrophe'` escape pattern.
  - Variable references (e.g. `$VAR`) are kept unquoted inside the double-quoted string unless the variable value may contain spaces, in which case single-quote wrapping is used.

### Module 3 — Source prefix migration (~15 files)
- Applies to files where `CURRENT` holds a `.zsh` file path and is used inside a `source $CURRENT` expression within a `bats_run_zsh` command string.
- `CURRENT` is renamed to `sourcePrefix` and its value changes from a bare path to a full source expression: `sourcePrefix="source '$BATS_TEST_DIRNAME/../file.zsh'"`.
- Call sites become: `bats_run_zsh "$sourcePrefix && function-name arg"`.
- The path is kept because `.zsh` autoload files are not in the PATH and cannot be invoked by name alone.

### Module 4 — Temp file elimination (6 files)
- Applies to files where `CURRENT` holds a path inside `$BATS_TMP_DIR` and the temp file content is a single-line wrapper of the form `function-name "$@"`.
- The temp file was a workaround for the old API. With the new single-string API it is no longer needed.
- The `CURRENT=` assignment, the `printf`/`cat` that writes the temp file, and the temp file itself are all removed.
- Every `bats_run_zsh "$CURRENT" arg1 arg2` becomes `bats_run_zsh "function-name arg1 arg2"`.
- For genuinely complex multi-line temp scripts (not the `"$@"` wrapper pattern), the content is written to a `local script=` variable inside the test body and sourced via `bats_run_zsh "source $script"`.

### Verification
- `bats <filepath>` is run after every individual file migration.
- If bats fails, the error is diagnosed and fixed before moving to the next file.
- Lessons from each failure inform subsequent migrations.

### Order of execution
1. Delete lint rule.
2. Migrate simple files (Module 2) — no-arg calls first, then files with args.
3. Migrate source-prefix files (Module 3).
4. Migrate temp-file files (Module 4).

## Testing Decisions

The `.bats` files are themselves the tests and the artifact — there is nothing to write new tests for. The verification strategy is:

- Run `bats <filepath>` after each file is migrated.
- A migration is considered correct when `bats` exits 0 with the same passing tests as before.
- `bats-lint <filepath>` is also run after each file to catch any lint regressions introduced during editing.

## Out of Scope

- Changes to the `bats_run_zsh` implementation itself — it is already correct.
- Migrating test files that do not use `CURRENT` and whose `bats_run_zsh` calls are already in the new single-string format.
- Adding new tests for scripts that currently have no test coverage.
- Refactoring test logic beyond what is required to update the calling convention.
- Updating documentation or READMEs about the bats conventions.

## Further Notes

- 155 `.bats` files total; 77 use `CURRENT`; 114 use `bats_run_zsh`; 662 call sites.
- The `bats_run_zsh` implementation passes the command string to `run zsh -c "$1"`, so the heredoc redirect (`<<<`) operates on the calling shell and is unaffected by the migration.
- The `sourcePrefix` naming convention is already present in at least one file in the codebase (`git.bats`) and serves as prior art for the pattern.
