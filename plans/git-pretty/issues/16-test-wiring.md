## TLDR

Wire `go-test` into git-file-test, lint-staged, and CLAUDE.md.

## What to build

Three wiring changes:

1. **git-file-test**: add `is-go` branch that collects Go files, resolves test paths via `go-test-path`, and runs `go-test` on unique packages
2. **lint-staged**: create `scripts/yarn/test-go` wrapper (resolves test paths, calls `go-test`), add `"test:go"` entry in package.json scripts
3. **CLAUDE.md**: document `go-test <filepath>` as the Go testing command

## Acceptance criteria

- [ ] `git-file-test` with a dirty `.go` file that has tests runs them
- [ ] `git-file-test` with a dirty `.go` file without tests does not error
- [ ] `scripts/yarn/test-go` runs go-test on given files
- [ ] CLAUDE.md documents `go-test <filepath>`
