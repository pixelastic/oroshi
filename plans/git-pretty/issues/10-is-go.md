## TLDR

Boolean helper `is-go` that detects Go source files by `.go` extension.

## What to build

ZSH autoload function at `_languages/go/is-go`, following the `is-python` pattern:

- Return 0 for files ending in `.go`
- Return 1 for everything else (directories, missing files, other extensions)
- Skip `_test.go` is NOT needed — test files are valid Go files
- BATS tests in `_languages/go/__tests__/is-go.bats`

## Acceptance criteria

- [ ] `is-go foo.go` exits 0
- [ ] `is-go foo_test.go` exits 0
- [ ] `is-go foo.py` exits 1
- [ ] `is-go /nonexistent` exits 1
- [ ] `is-go /some/directory/` exits 1
- [ ] BATS tests pass
