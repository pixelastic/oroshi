## TLDR

Move mutex into `fzf-history-update-cache`, rename `fzf-history-refresh-cache` to `fzf-history-regenerate-cache`, and remove the count parameter from `update-cache`.

## What to build

**`fzf-history-update-cache`** — incremental update, mutex-protected
- No count parameter — always processes `HISTORY_DIFF_COUNT`
- Acquires mutex at entry (`mkdir lockDir || return 0`)
- Releases mutex on exit
- Used by: eager path (inline), lazy path (background)

**`fzf-history-regenerate-cache`** — full rebuild from scratch
- Deletes `cache` and `last-history-line-count`
- Calls `fzf-history-update-cache` with `--progress`
  (`HISTORY_DIFF_COUNT` now equals `CURRENT_HISTORY_LINE_COUNT` since meta was deleted)
- No mutex logic of its own — inherited from `update-cache`
- Used by: `ctrl-r --refresh-cache` (manual, foreground with spinner)

**Call sites to update:**
- `fzf-history-source-eager`: calls `fzf-history-update-cache` (no change needed)
- `fzf-main` (lazy): calls `ctrl-r --refresh-cache` → rename to `ctrl-r --regenerate-cache`, or keep the flag name and rename only the function
- `--refresh-cache` flag → rename to `--regenerate-cache` in script header + usage comment

## Behavioral notes

- Eager with mutex taken (concurrent lazy from another terminal): skip update, serve stale cache. Acceptable — off by a few entries at most.
- `regenerate-cache` with mutex taken: print "Cache update already in progress, skipping." on stderr and return. `update-cache` must propagate this distinction so `regenerate-cache` can display the message (e.g. return code 2 = mutex taken).

## Acceptance criteria

- [ ] Mutex lives only in `fzf-history-update-cache`
- [ ] `fzf-history-update-cache` has no count parameter
- [ ] `fzf-history-refresh-cache` renamed to `fzf-history-regenerate-cache`
- [ ] `--refresh-cache` flag renamed to `--regenerate-cache`
- [ ] All existing tests pass
- [ ] New test: concurrent `update-cache` calls — second one is a no-op (mutex)
- [ ] `regenerate-cache` prints "Cache update already in progress, skipping." on stderr when mutex is taken
