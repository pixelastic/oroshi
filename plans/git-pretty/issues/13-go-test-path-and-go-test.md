## TLDR

`go-test-path` resolves a Go file to its test file, `go-test` runs Go tests.

## What to build

Two ZSH autoload functions at `_languages/go/`:

### `go-test-path`

- Given `foo.go`, check if `foo_test.go` exists in the same directory — if so, return it
- Given `foo_test.go`, return it directly
- Return empty string (exit 1) if no test file found
- BATS tests in `__tests__/go-test-path.bats`

### `go-test`

- Accepts one or more `.go` file paths
- Resolves each file to its Go package directory (the parent dir)
- Deduplicates package paths
- Runs `go test ./relative/package/...` for each unique package
- Exit with go test's exit code
- BATS tests in `__tests__/go-test.bats`

## Acceptance criteria

- [ ] `go-test-path foo.go` returns `foo_test.go` when it exists
- [ ] `go-test-path foo_test.go` returns `foo_test.go`
- [ ] `go-test-path foo.go` returns empty when no test exists
- [ ] `go-test parser.go` runs `go test` on the parser's package
- [ ] `go-test a.go b.go` deduplicates packages
- [ ] BATS tests pass for both commands
