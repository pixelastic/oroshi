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

### Issue 01 — Go scaffold
- Go ignores directories starting with `_` (`__lib/`). `go mod tidy` and `go list ./...` won't find packages there. Build must target the path explicitly.
- GVM overrides `cd` with a hook that searches for `.go-version`/`.go-pkgset`. Use `builtin cd` in scripts to bypass it under `err_return`.
- Build script must `source ~/.gvm/scripts/gvm` to make `go` available in non-interactive shells (lazy alias not set).
- `.go-version` file at repo root needed for GVM to auto-select the correct Go version.
- Linter requires both `set -e` and `setopt local_options err_return` in ZSH scripts.

### Issue 02 — Stderr parser
- Go subpackages in `__lib/` work fine with co-located `_test.go` files; just run `go test` with the explicit path.
- Git `\r` handling: last `\r`-delimited segment is the "current" state (previous segments are overwritten). Use `strings.LastIndex` not `TrimLeft`.

### Issue 03 — Theme loader
- lipgloss v1.1.0 (latest stable; v2 is beta-only) uses `lipgloss.Color("73")` (string type conversion) for ANSI 256 colors.
- Inject a `CommandRunner` function type for bin-zsh calls to enable test mocking without real shell execution.
- Go tests in `__lib/` subpackages use co-located `_test.go` with `package theme` (same package) — gives access to unexported types like `colorEntry`.

### Issue 04 — TUI progress bar
- bubbles v1.0.0 uses `progress.WithSolidFill(color string)` for solid colors, not `WithColors` (v2 API).
- `progress.ViewAs(percent)` renders a static bar at a given percentage — ideal for non-animated, event-driven updates. Avoids animation frame handling.
- `progress.SetPercent` in v1 returns `tea.Cmd` (pointer receiver), not void — use `ViewAs` instead for value-type Models.

### Issue 05 — Execute and wire
- Cross-package imports within `__lib/` work fine (e.g. `runner` importing `parser` and `tui`). Go ignores `_`-prefixed dirs for auto-discovery but resolves explicit imports normally.
- `go test ./...` won't find `__lib/` subpackages. Must list each test package explicitly: `go test ./path/__lib/tui/ ./path/__lib/runner/` etc.
- For real-time git progress, split stderr on both `\r` and `\n` using a custom `bufio.Scanner` split function. The parser's built-in `\r` handling becomes a no-op but stays as defense-in-depth.
- BubbleTea renders View() to stdout. Errors must be printed to stderr by main.go after `p.Run()` returns, not shown in View().
- Use `exec.CommandContext` with a cancelable context for Ctrl+C cleanup — cancel the context after `p.Run()` returns to kill the subprocess.

### Issue 05b — Manual TUI smoke test
- BubbleTea's `tea.NewProgram` opens `/dev/tty` directly — cannot run in headless/CI environments. Manual TUI verification requires a real terminal.
- Build output goes to `scripts/bin/git-branch-push-pretty/build/` (not alongside `__lib/`).

### Issue 06 — Summary line
- `New(ansiColor)` kept for backward compat in existing tests. `NewWithSummary(Config{...})` is the full constructor used by main.go.
- `viewSummary()` guards on `branchName == ""` to distinguish simple vs full mode.
- RefUpdate events with only `Remote` (destination line) are skipped in `EventToMsg` — only ref hash lines forwarded.

### Issue 07 — Ctrl+O toggle
- `StreamStderr` sends `RawLineMsg` before the parsed typed message for each line — raw buffer accumulates all stderr regardless of toggle state.
- `RawPanel()` accessor includes the separator for consistent visual between in-TUI and post-exit output.
- BubbleTea quits on `DoneMsg` so no guard needed for Ctrl+O after done — no further key events arrive.
