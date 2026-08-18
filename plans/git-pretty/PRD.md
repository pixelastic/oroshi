## Problem Statement

Git push dumps verbose plumbing output (object enumeration, delta compression, transfer stats) that has no value for interactive use. The user needs: success/failure status, which commits were pushed and where, and a progress indicator during transfer. Currently, all of this is buried in noise.

## Solution

A Go binary (`git-branch-push-pretty`) that wraps `git-branch-push`, captures its stderr, and renders a clean TUI: a progress bar during transfer, a one-line colored summary on completion, and raw output on demand via Ctrl+O toggle. Built with the Charm ecosystem (bubbletea + bubbles + lipgloss) as a foundation for future pretty CLI tools.

## User Stories

1. As a developer, I want to see a visual progress bar when pushing, so that I know the transfer is progressing
2. As a developer, I want a clean one-line summary after push (branch, remote, commit range), so that I can confirm what was pushed without reading plumbing output
3. As a developer, I want to press Ctrl+O during a push to toggle raw git output, so that I can debug issues without re-running the command
4. As a developer, I want the pretty output to use my existing color theme and icons, so that it feels consistent with my other ZSH tools
5. As a developer, I want to use `vbps` as before and get the pretty output automatically, so that my muscle memory is preserved
6. As a developer, I want force-push (`vbpsf`) to work identically through the pretty wrapper, so that all push variants benefit
7. As a developer, I want remote messages (like GitHub PR creation URLs) to be shown after the summary, so that I don't lose useful information
8. As a developer, I want errors to be shown unfiltered, so that I can diagnose push failures
9. As a developer, I want the progress bar to show the current git phase name (e.g., "Compressing objects"), so that I know what git is doing
10. As a developer, I want "up to date" pushes to show a brief confirmation, so that I know the command ran
11. As a developer, I want Ctrl+O to be a true toggle (open/close), so that I can dismiss the raw output if I don't need it anymore

## Implementation Decisions

### Architecture

- `git-branch-push-pretty` is a compiled Go binary, not a ZSH function
- It lives in `scripts/bin/git-branch-push-pretty/` (in PATH via oroshi's path auto-discovery)
- It accepts the exact same arguments as `git-branch-push` and forwards them all
- It calls `git-branch-push` internally via `bin-zsh git-branch-push [args] --progress`
- The `--progress` flag forces git to emit progress to stderr even when piped

### Go project structure

- Root-level `go.mod` / `go.sum` (like `package.json` for Node)
- Source in `scripts/bin/git-branch-push-pretty/__lib/main.go`
- Build script in `scripts/bin/git-branch-push-pretty/__lib/build` (ZSH one-liner: `go build -o ../ .`)
- Compiled binary at `scripts/bin/git-branch-push-pretty/git-branch-push-pretty`

### Three Go modules

**parser** — Pure function. Takes a raw stderr line, returns structured data: line type (progress, refUpdate, remoteMessage, error, noise), phase name, percentage, ref range, branch, remote, raw text. Regex-based. No side effects.

**tui** — Bubbletea Model/Update/View. Consumes parsed events. Renders progress bar (bubbles/progress component) with phase name. Handles Ctrl+O toggle for raw output. On completion, renders lipgloss-styled summary line.

**theme** — Reads `$OROSHI_ROOT/tools/term/zsh/config/theming/dist/colors.json` and `icons.json`. Provides color/icon lookup. Also calls `bin-zsh git-branch-color <branch>` and `bin-zsh git-remote-color <remote>` for dynamic branch/remote color resolution.

### TUI rendering

- During push: single line with phase name + progress bar + percentage
- Ctrl+O: toggle raw stderr output below the pretty line (open/close)
- On success: summary replaces progress bar — icon + colored branch + arrow + colored remote + commit range
- On "up to date": summary with "(up to date)" instead of commit range
- On error: raw git error output, unfiltered
- Remote messages (GitHub PR URLs): passed through after summary
- Force push: same display as normal push (no visual distinction)

### ZSH alias changes

All push aliases updated to use `git-branch-push-pretty` instead of `git-branch-push`. The underlying `git-branch-push` function remains unchanged.

### Dependencies

- Go: bubbletea, bubbles, lipgloss (Charm ecosystem)
- The existing `git-branch-push` ZSH function is unchanged and still usable directly
- `bin-zsh` bridges Go binary to ZSH autoload functions

## Testing Decisions

- Unit test the **parser** module thoroughly with Go table-driven tests
- Cover every git stderr line type: progress lines, ref updates, remote messages, errors, noise lines, "up to date"
- TUI module is not unit tested — validated visually
- Theme module: testable by providing JSON input and checking lookups
- Existing BATS tests for `git-branch-push` remain unchanged (function is untouched)
- Tests live in `scripts/bin/git-branch-push-pretty/__tests__/`

## Out of Scope

- Pretty wrappers for git pull, fetch, clone (future sidequests)
- Generic `pretty-exec` wrapper for arbitrary commands
- Migrating Rust `Cargo.toml` to root level
- Progress bar customization (width, colors, style)
- Any changes to `git-branch-push` itself

## Further Notes

- This is the first Go code in the oroshi repo. It establishes the pattern for future Go tools: root-level `go.mod`, source in `scripts/bin/<name>/__lib/`, build script adjacent.
- The Charm ecosystem (bubbletea/lipgloss) was chosen as a foundation for future TUI tools with consistent theming.
- The `--progress` flag approach was chosen over PTY emulation (`creack/pty`) for simplicity. If edge cases arise where `--progress` is insufficient, PTY can be added later.
