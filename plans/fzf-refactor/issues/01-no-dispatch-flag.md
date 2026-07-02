## TLDR

Add `--no-dispatch` flag to `init.zsh` so FZF Scripts can be sourced without executing — enables unit testing of internal functions.

## What to build

Add a `--no-dispatch` flag to the `zparseopts` block in `scripts/bin/fzf/__lib/init.zsh`. When this flag is present, `fzf-dispatch` becomes a no-op (returns immediately without calling any Lifecycle Function).

This allows test files to source a script with `--no-dispatch` and then call individual functions like `fzf-history-entries` or `fzf-history-highlight-line` directly.

The flag is parsed alongside the existing flags (`--source`, `--options`, `--postprocess`, `--preview`). When `--no-dispatch` is set, `fzf-dispatch` returns 0 without dispatching.

## Behavioral Tests

**Scenario: --no-dispatch prevents execution**
- calling a FZF Script with `--no-dispatch` produces no output and exits 0
- after sourcing with `--no-dispatch`, functions defined in the script are callable

**Scenario: existing behavior unchanged**
- calling a FZF Script with `--source` still dispatches to `fzf-source`
- calling a FZF Script with no arguments still dispatches to `fzf-main`

## Acceptance criteria

- [ ] `--no-dispatch` added to `zparseopts` in `init.zsh`
- [ ] `fzf-dispatch` returns immediately when `--no-dispatch` is set
- [ ] Existing tests for all FZF Scripts still pass
- [ ] New behavioral tests cover both `--no-dispatch` and unchanged dispatch
