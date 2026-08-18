## TLDR

Set up the Go project: root-level go.mod, source directory, build script, binary that compiles and runs.

## What to build

Create the Go project infrastructure for the first Go binary in oroshi:

- `go.mod` at repo root with module path `github.com/pixelastic/oroshi`
- `scripts/bin/git-branch-push-pretty/__lib/main.go` — minimal `package main` that prints a placeholder message and exits
- `scripts/bin/git-branch-push-pretty/__lib/build` — ZSH script that runs `go build -o ../git-branch-push-pretty .`
- Add `go.sum` and compiled binary to `.gitignore`
- Add Charm dependencies: bubbletea, bubbles, lipgloss

Run `build`, verify the binary is created at `scripts/bin/git-branch-push-pretty/git-branch-push-pretty` and is callable from the shell.

## Scaffolding Tests

- Binary compiles without errors
- Running the binary with `--help` or no args prints usage and exits 0

## Acceptance criteria

- [ ] `go.mod` exists at repo root with bubbletea, bubbles, lipgloss dependencies
- [ ] `main.go` compiles into a working binary
- [ ] `build` script produces the binary at the expected path
- [ ] Binary is callable by name from the shell (in PATH via scripts/bin/ auto-discovery)
- [ ] `go.sum` and compiled binary are gitignored
