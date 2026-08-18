## TLDR

Install golangci-lint, goimports, gofumpt and configure `.golangci.yml` at repo root.

## What to build

Install scripts and configuration for Go linting/formatting toolchain:

- Install script at `scripts/install/_languages/go/golangci-lint` (follow existing install script pattern)
- Install script at `scripts/install/_languages/go/goimports`
- Install script at `scripts/install/_languages/go/gofumpt`
- `.golangci.yml` at repo root with sensible defaults (enable govet, errcheck, staticcheck, unused, gosimple)
- Add `go test`, `go vet`, `golangci-lint` to Claude allow-list (`tools/ai/claude/config/hooks/allow-list.json`)

## Acceptance criteria

- [ ] `golangci-lint run ./...` works from repo root
- [ ] `goimports` is available in PATH
- [ ] `gofumpt` is available in PATH
- [ ] `.golangci.yml` exists at repo root with enabled linters
- [ ] `go test`, `go vet`, `golangci-lint` are in the Claude allow-list
