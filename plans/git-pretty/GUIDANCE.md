## Guidance

### Project context

First Go project in oroshi. Establishes patterns for future Go binaries.

### Go conventions

- Root-level `go.mod` (module `github.com/pixelastic/oroshi`)
- Source in `scripts/bin/<name>/__lib/`
- Build script in `scripts/bin/<name>/__lib/build`
- Compiled binary at `scripts/bin/<name>/<name>`
- Go tests in `scripts/bin/<name>/__tests/`

### Key paths (relative to repo root)

- `scripts/bin/git-branch-push-pretty/__lib/main.go` — Go entry point
- `scripts/bin/git-branch-push-pretty/__lib/build` — build script
- `tools/term/zsh/config/functions/autoload/git/branch/git-branch-push` — wrapped ZSH function
- `tools/term/zsh/config/aliases/git/branch.zsh` — aliases to update
- `tools/term/zsh/config/theming/dist/colors.json` — color definitions
- `tools/term/zsh/config/theming/dist/icons.json` — icon definitions
- `scripts/bin/bin-zsh` — bridge to call ZSH autoload functions from non-ZSH contexts

### How to call ZSH functions from Go

Use `exec.Command("bin-zsh", "function-name", "arg1", "arg2")`. The `bin-zsh` script sources ZSH autoload functions and executes them.

### Testing

- Go tests: `go test ./scripts/bin/git-branch-push-pretty/__tests/...`
- Build: `scripts/bin/git-branch-push-pretty/__lib/build`

### Charm ecosystem

- bubbletea: runtime/event loop (Model/Update/View pattern)
- bubbles: pre-built components (progress bar, spinner)
- lipgloss: text styling (colors, borders, padding)
- Fetch up-to-date docs via Context7 MCP before writing Go code

### Git stderr format

- Progress lines use `\r` (carriage return) to overwrite in-place
- `--progress` flag forces git to emit progress even when stderr is piped
- The flag is injected by the Go binary when calling git-branch-push

## Discoveries
