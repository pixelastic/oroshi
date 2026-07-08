## TLDR

Add `--fix` flag to `python-lint`: auto-format, auto-fix lint violations, then report what remains.

## What to build

Update `scripts/bin/python/python-lint` to accept a `--fix` flag. When passed:
1. Run `ruff format` on the file (auto-format: indentation, quotes, line length)
2. Run `ruff check --fix` on the file (auto-fix lint violations)
3. Run `ruff check` and output remaining violations (exit non-zero if any remain)

Without `--fix`, behavior is unchanged: run `ruff check` only and report violations.

The `--fix` flag is the public interface agents call. The three ruff steps are implementation details internal to the script.

Also add a bats test file at `scripts/bin/python/__tests__/python-lint.bats`.

## Behavioral Tests

**When `--fix` is passed and the file has auto-fixable violations:**
- The file is modified in place
- Exit code is 0 if no violations remain after fixing

**When `--fix` is passed and the file has unfixable violations:**
- The file is modified in place for the fixable parts
- Remaining violations are printed to stdout/stderr
- Exit code is non-zero

**Without `--fix`:**
- File is not modified
- Existing behavior preserved (violations reported, exit non-zero)

## Acceptance criteria

- [ ] `python-lint --fix <file>` runs ruff format then ruff check --fix then ruff check
- [ ] `python-lint <file>` (no flag) behavior unchanged
- [ ] File is modified in place when `--fix` is passed
- [ ] Exit 0 when no violations remain after fixing
- [ ] Exit non-zero when unfixable violations remain
- [ ] Bats tests cover the two `--fix` scenarios above
