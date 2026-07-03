## Guidance

**Goal:** Centralize file colorization in `fzf-source-files` so both `ctrl-p` and `ctrl-shift-p` produce colorized two-column output.

**Plan directory:** `plans/ctrl-shift-p-colors/`

**Key files (relative to repo root):**
- `scripts/bin/fzf/__lib/fzf-source-files.zsh` — lib to modify (core fix)
- `scripts/bin/fzf/__lib/fzf-colorize-path.zsh` — helper to source and use
- `scripts/bin/fzf/__lib/__tests__/fzf-source-files.bats` — new test file to create
- `scripts/bin/fzf/ctrl-p` — script to refactor (issue 02)
- `scripts/bin/fzf/__tests__/ctrl-p.bats` — existing tests, must stay green

**Prior art:**
- `fzf-regexp-common.zsh` sources `fzf-colorize-path.zsh` at its own top — follow this pattern
- `fzf-colorize-path.bats` — model for the new `fzf-source-files.bats` (mock setup, bats_run_zsh with inline source prefix)
- `fzf-source-directories.zsh` — reference for how a lib colorizes its output (but uses `colorize` directly; `fzf-source-files` uses `fzf-colorize-path` for extension + executable logic)

**Conventions:**
- `fzf-colorize-path` takes `<display-path> [real-path]`; result in `$REPLY` (no subshell)
- Column format: `absPath▮colorizedDisplay`
- `colors-load-definitions` and `filetypes-load-definitions` are idempotent — call them where needed, not at script top level
- Linting: `zsh-lint <file>` for zsh, `bats-lint <file>` for bats
- Testing: `bats <filepath>`

## Discoveries

### Issue 01 — Colorize fzf-source-files
- `fzf-colorize-path` uses `$REPLY` (no subshell); call it, then read `$REPLY` immediately before any other call that might overwrite it.
- Test column splitting in bats: `col1="${output%%▮*}"` / `col2="${output#*▮}"` — clean and readable.
- `bats_mock` for `filetypes-load-definitions` / `colors-load-definitions` must define the stubs *before* calling `bats_mock` in `setup()`.
