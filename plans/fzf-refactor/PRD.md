## Problem Statement

The ctrl-r FZF Script is functionally correct but hard to maintain: `fzf-source` and `fzf-colorize` are monolithic (~100 lines each), the history parsing loop is duplicated 5 times, cache paths are defined independently in two places, and the caching strategy (when to colorize inline vs defer to background) is buried in nested conditionals. A file-based semaphore is used to communicate between pipeline stages when a simpler variable-based approach is possible. There is no way to manually trigger a full cache rebuild.

## Solution

Refactor ctrl-r into small, single-concern functions following the **Eager**/**Lazy** colorization model. **Eager** colorizes new entries synchronously when the **History diff** is small (≤ threshold). **Lazy** serves raw entries and defers colorization to a background process when the **History diff** is large. A shared `fzf-history-update-cache` function eliminates duplication between the two paths. A `--refresh-cache` flag provides a manual full rebuild with a progress spinner. The file-based semaphore is eliminated — `fzf-main` computes the **History diff** directly to decide whether to launch background colorization.

All terms follow `scripts/bin/fzf/GLOSSARY-ctrl-r.md`.

## User Stories

1. As a developer, I want ctrl-r to open instantly when my **Cache** is fresh, so that I don't wait for unnecessary processing.
2. As a developer, I want new history entries to appear syntax-highlighted when the **History diff** is small, so that I get colored output without delay.
3. As a developer, I want new history entries to appear immediately (uncolored) when the **History diff** is large, so that I don't wait for a slow colorization pass.
4. As a developer, I want the **Cache** to be rebuilt in the background after a **Lazy** ctrl-r session, so that the next session is fully colored.
5. As a developer, I want to run `ctrl-r --refresh-cache` manually with a progress spinner, so that I can force a full rebuild and see its progress.
6. As a developer, I want each function in ctrl-r to have a single concern, so that I can understand and modify the caching logic without reading 100-line functions.
7. As a developer, I want the history parsing logic (strip timestamps, dedup) in one place, so that changes to the HISTFILE format only require one update.
8. As a developer, I want cache files grouped in a `ctrl-r/` subdirectory, so that I can find and manage them easily.

## Implementation Decisions

### Colorization strategies: Eager and Lazy

Two variables are computed at script startup: `HISTORY_MODE` ("eager" or "lazy") and `HISTORY_DIFF` (count of new HISTFILE lines since last cache build). The threshold is `LAZY_THRESHOLD=100`, defined at the top-level for easy adjustment.

- **Eager** (diff ≤ threshold): colorize new entries synchronously, update the **Cache**, serve the full colored output to fzf.
- **Lazy** (diff > threshold): serve new entries as `raw▮raw` followed by the existing **Cache** (already colored), then `fzf-main` launches `ctrl-r --refresh-cache` in background after fzf exits.

### Semaphore elimination

The `colorize-needed` semaphore file is removed. `fzf-main` reads `HISTORY_MODE` directly (a top-level variable) to decide whether to launch background colorization. No inter-process communication needed.

### Unified cache rebuild via --refresh-cache

A single `--refresh-cache` flag replaces the old `--colorize` flag. It serves both manual (foreground with spinner) and automatic (background, stdout/stderr redirected to /dev/null) use cases. The spinner writes to stderr — invisible when backgrounded, visible when run manually. It uses two passes: first `fzf-history-entries | wc -l` for the total, then colorization with a `n/total` counter.

### Shared cache update function

`fzf-history-update-cache` is the single place where new entries are colorized and prepended to the **Cache**. Called by both `fzf-history-source-eager` (synchronous) and `fzf-history-refresh-cache` (with **Mutex** and spinner).

### Color cache removal

The separate `ctrl-r-colors.cache` file is removed. Full rebuilds re-colorize everything — the cost is acceptable since `--refresh-cache` provides a progress spinner for manual use.

### Highlighting deps sourced at top-level

`zsh.zsh` and `aliases/index.zsh` are sourced unconditionally at the top of the script, like `ctrl-p` sources `colors-load-definitions` and `filetypes-load-definitions`. No conditional check for `_zsh_highlight` — it is always available. No `|| true` fallbacks.

### Cache file organization

All cache files move to `$OROSHI_TMP_FOLDER/fzf/ctrl-r/`:
- `cache` — pre-formatted `raw▮colored` entries served to fzf
- `last-history-line-count` — HISTFILE line count at last cache build (freshness heuristic)
- `colorize.lock/` — **Mutex** directory (mkdir atomicity), contains `pid` file for stale lock detection

### Function inventory (in file order)

1. `fzf-source` — dispatcher: reads `HISTORY_MODE`, calls **Eager** or **Lazy**
2. `fzf-options` — unchanged
3. `fzf-postprocess` — unchanged
4. `fzf-main` — standard pipeline; if `HISTORY_MODE` is lazy, launches background `--refresh-cache` after fzf exits
5. `fzf-history-source-eager` — calls `fzf-history-update-cache`, then cats the **Cache**
6. `fzf-history-source-lazy` — formats new entries as `raw▮raw`, cats existing **Cache**
7. `fzf-history-update-cache` — colorizes new entries via `fzf-history-entries` + `fzf-history-format-line`, prepends to **Cache**, updates meta
8. `fzf-history-refresh-cache` — acquires **Mutex**, calls `fzf-history-update-cache`, spinner on stderr, releases **Mutex**
9. `fzf-history-entries [n]` — reads HISTFILE in reverse, strips timestamps, deduplicates, emits on stdout. No argument = all entries.
10. `fzf-history-format-line` — takes a raw command, calls `fzf-history-highlight-line`, sets REPLY to `raw▮colored`
11. `fzf-history-highlight-line` — converts zsh `region_highlight` entries to ANSI escape sequences, sets REPLY

### Function ordering rationale

Standard Lifecycle Functions first (source, options, postprocess, main) — same order as all other FZF Scripts. Then specialized functions from most general to most specific, ending with the ANSI conversion utility.

## Testing Decisions

Tests exercise external behavior in isolation — given a known HISTFILE or input, the function produces the expected output. Tests do not verify implementation details.

**Tested: `fzf-history-entries`**
- Given a HISTFILE with timestamps and duplicates, outputs clean deduplicated commands in reverse chronological order.
- Given a count argument, outputs only that many recent entries.
- Handles empty lines, edge cases in timestamp format.

**Tested: `fzf-history-highlight-line`**
- Given a command string with zsh-syntax-highlighting loaded, produces ANSI-colored output.
- Region highlight entries are correctly converted to escape sequences.
- Output contains no unclosed ANSI sequences.

**Not tested:**
- `fzf-history-update-cache` — tested indirectly via `fzf-source` (existing tests cover cache-fresh and cache-stale scenarios).
- `fzf-history-format-line` — thin wrapper, tested indirectly.
- `fzf-history-source-eager` / `fzf-history-source-lazy` — tested indirectly via existing `fzf-source` tests.
- `fzf-history-refresh-cache` — involves lock management and background processes, not suitable for unit tests.

Prior art: `scripts/bin/fzf/__tests__/ctrl-r.bats` (existing tests for fzf-source and fzf-postprocess).

## Out of Scope

- Changing the `raw▮colored` format — it is the standard FZF Script format.
- Changing the HISTFILE format or ZSH history configuration.
- Making the highlighting engine pluggable (it is always zsh-syntax-highlighting).
- Performance optimization of `fzf-history-highlight-line` itself — the function works, we just need to isolate it.
- Modifying `init.zsh` or the FZF dispatch system.

## Further Notes

- The existing `ctrl-r.bats` tests should continue to pass after the refactoring — they test the external interface (`--source`, `--postprocess`, `--options`) which does not change.
- `HISTORY_MODE` and `HISTORY_DIFF` are computed even when `--refresh-cache` is used. This is harmless — the cost is one `wc -l` call.
