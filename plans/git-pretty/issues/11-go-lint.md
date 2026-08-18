## TLDR

ZSH wrapper `go-lint` around golangci-lint with JSON output and --fix support.

## What to build

ZSH autoload function at `_languages/go/go-lint`:

- Accepts one or more `.go` file paths
- Runs `golangci-lint` on the resolved package directories
- Flags:
  - `--json`: output JSON array of violations (for neovim), each with `{file, code, level, line, endLine, column, endColumn, message}`
  - `--fix`: run `golangci-lint --fix` first, then report remaining violations
- Default output: plain text (golangci-lint default)
- Exit 0 if clean, 1 if violations found
- Uses `jq` to transform golangci-lint JSON output into the unified violation format used by zsh-lint/bats-lint
- BATS tests in `_languages/go/__tests__/go-lint.bats`

## Acceptance criteria

- [ ] `go-lint clean.go` exits 0
- [ ] `go-lint dirty.go` exits 1 with violations
- [ ] `go-lint --json dirty.go` outputs JSON array with file/line/code/message fields
- [ ] `go-lint --fix dirty.go` auto-fixes then reports remaining
- [ ] Multiple files accepted
- [ ] BATS tests pass
