## TLDR

Add multi-file `--in-place` support to zsh-fix, error on multi-file without --in-place.

## What to build

Extend `scripts/bin/zsh/zsh-fix/zsh-fix` to accept multiple file arguments:
- `zsh-fix --in-place file1 file2 file3` — pass all files to a single `beautysh --indent-size 2` invocation (no tmpdir, no loop)
- `zsh-fix file1 file2` (without --in-place) — print error message and exit 1

This enables batch formatting in ~60ms total instead of 60ms per file.

Add two tests to `scripts/bin/zsh/zsh-fix/__tests__/zsh-fix.bats`.

## Behavioral Tests

**Multi-file in-place**
- --in-place with two files: both files are formatted correctly

**Multi-file without --in-place errors**
- two files without --in-place: exits with non-zero status and error message

## Acceptance criteria

- [ ] `zsh-fix --in-place file1 file2` formats both files via a single beautysh call
- [ ] `zsh-fix file1 file2` (no --in-place) prints error and exits 1
- [ ] All tests pass: `bats scripts/bin/zsh/zsh-fix/__tests__/zsh-fix.bats`
