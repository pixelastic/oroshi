## TLDR

Wire `go-lint` into git-file-lint, lint-staged, and CLAUDE.md.

## What to build

Three wiring changes:

1. **git-file-lint**: add `is-go` branch that collects Go files and runs `go-lint --fix`, with a `displayGoLintErrors` function for plain-text output (same pattern as Python)
2. **lint-staged**: create `scripts/yarn/lint-go` wrapper (calls `go-lint --fix "$@"`), add `"lint:go"` entry in package.json scripts
3. **CLAUDE.md**: document `go-lint <filepath>` as the Go linting command

## Acceptance criteria

- [ ] `git-file-lint` with a dirty `.go` file reports go-lint violations
- [ ] `git-file-lint` with no dirty Go files does not error
- [ ] `scripts/yarn/lint-go` runs go-lint on given files
- [ ] CLAUDE.md documents `go-lint <filepath>`
