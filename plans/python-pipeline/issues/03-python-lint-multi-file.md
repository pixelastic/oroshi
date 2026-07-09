## TLDR

Extend `python-lint` to accept and process multiple file arguments.

## What to build

Modify `scripts/bin/python/python-lint` so that all positional arguments are treated as input files. The script loops over each file internally, applying the same ruff format + check + report logic per file. The `--fix` and `--json` flags continue to apply to each file in the batch.

Exit non-zero if any file has remaining violations.

## Acceptance criteria

- [ ] `python-lint file1.py file2.py` lints both files
- [ ] `python-lint --fix file1.py file2.py` auto-fixes and reports remaining violations for both
- [ ] Exit code is non-zero if any file has violations
- [ ] Single-file invocation still works as before
- [ ] `zsh-lint` passes on the modified script
