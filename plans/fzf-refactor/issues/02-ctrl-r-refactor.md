## TLDR

Rewrite ctrl-r into single-concern functions using the eager/lazy colorization model, with behavioral tests for `fzf-history-entries` and `fzf-history-highlight-line`.

## What to build

Rewrite `scripts/bin/fzf/ctrl-r` following the PRD. The external interface (`--source`, `--options`, `--postprocess`) does not change. Internally, the two monolithic functions (`fzf-source` ~100 lines, `fzf-colorize` ~106 lines) are replaced by 11 single-concern functions.

**Top-level setup:**
- Source highlighting deps (`zsh.zsh`, `aliases/index.zsh`) unconditionally — no `|| true`, no availability check
- Define `LAZY_THRESHOLD=100` as a top-level constant
- Compute `HISTORY_MODE` ("eager"/"lazy") and `HISTORY_DIFF` at startup
- Define `CTRL_R_DIR="$OROSHI_TMP_FOLDER/fzf/ctrl-r"`

**Cache reorganization:**
- Move cache files from `$OROSHI_TMP_FOLDER/fzf/ctrl-r.*` to `$OROSHI_TMP_FOLDER/fzf/ctrl-r/`
- Files: `cache`, `last-history-line-count`, `colorize.lock/`
- Remove: `colorize-needed` semaphore, `ctrl-r-colors.cache`

**Function inventory (in file order):**
1. `fzf-source` — dispatcher: reads `HISTORY_MODE`, calls eager or lazy
2. `fzf-options` — unchanged
3. `fzf-postprocess` — unchanged
4. `fzf-main` — pipeline + background `--refresh-cache` if lazy
5. `fzf-history-source-eager` — calls update-cache, cats cache
6. `fzf-history-source-lazy` — formats new entries as `raw▮raw`, cats existing cache
7. `fzf-history-update-cache` — colorizes new entries, prepends to cache, updates meta
8. `fzf-history-refresh-cache` — mutex (inline), calls update-cache, spinner on stderr (two-pass: count then colorize with n/total)
9. `fzf-history-entries [n]` — reads HISTFILE in reverse, strips timestamps, deduplicates, stdout
10. `fzf-history-format-line` — raw → REPLY = `raw▮colored`
11. `fzf-history-highlight-line` — region_highlight → ANSI, REPLY

**Flag changes:**
- Replace `--colorize` with `--refresh-cache` (single entry point for both manual and background use)
- Parse `--refresh-cache` at top of script, handle in `fzf-main`

**Removals:**
- Color cache file and associated logic
- `isHighlighting` conditional — highlighting is always available
- `|| true` on source commands
- `colorize-needed` semaphore file and associated logic

## Behavioral Tests

Tests use `--no-dispatch` (from issue 01) to source ctrl-r and call functions directly.

**fzf-history-entries:**
- outputs deduplicated commands in reverse chronological order
- strips ZSH extended history timestamp prefix (`: 1680000001:0;`)
- skips empty lines
- with count argument, outputs only that many recent entries
- with no argument, outputs all entries
- duplicate commands keep only the most recent occurrence

**fzf-history-highlight-line:**
- produces ANSI-colored output for a known command
- output contains no unclosed ANSI sequences
- sets REPLY (does not print to stdout)

**Existing tests:**
- All existing `ctrl-r.bats` tests still pass (cache path change is transparent — tests use `$OROSHI_TMP_FOLDER` which is mocked)

## Acceptance criteria

- [ ] All 11 functions implemented and correctly wired
- [ ] `HISTORY_MODE` and `HISTORY_DIFF` computed at top-level
- [ ] Cache files under `$OROSHI_TMP_FOLDER/fzf/ctrl-r/`
- [ ] `--refresh-cache` works in foreground (with spinner) and background (silent)
- [ ] Mutex prevents concurrent `--refresh-cache` processes
- [ ] Color cache file removed
- [ ] Semaphore file removed
- [ ] `fzf-history-entries` behavioral tests pass
- [ ] `fzf-history-highlight-line` behavioral tests pass
- [ ] All existing `ctrl-r.bats` tests pass
- [ ] No `|| true` on source commands
- [ ] No `isHighlighting` conditional
