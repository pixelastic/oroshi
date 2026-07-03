# ctrl-r

History search with syntax-highlighted, cached output served through fzf.

## Language

**Eager**:
A colorization strategy where new history entries are colorized synchronously before fzf is displayed.
_Avoid_: inline, immediate, foreground, sync

**Lazy**:
A colorization strategy where new history entries are served raw and colorization is deferred to a background process after fzf exits.
_Avoid_: deferred, background, async, raw mode

**History diff**:
The number of new lines in HISTFILE since the cache was last built — compared against a lazy threshold to choose **Eager** or **Lazy**.
_Avoid_: diff, gap, delta, new entries count

**Cache**:
The `ctrl-r/` directory and its files (`cache`, `last-history-line-count`) that store pre-formatted history entries so fzf can be served instantly.
_Avoid_: output cache, color cache, store

**Mutex**:
The `colorize.lock/` directory whose existence prevents concurrent background colorization processes — uses `mkdir` atomicity for safe locking, stores the owner PID for stale lock detection.
_Avoid_: lock, semaphore, lock file

## Relationships

- The **History diff** determines whether **Eager** or **Lazy** is used
- **Eager** updates the **Cache** synchronously before serving
- **Lazy** serves from the **Cache** as-is, then triggers a background process that acquires the **Mutex** and rebuilds the **Cache**
- The **Mutex** protects the **Cache** from concurrent writes

## Flagged ambiguities

- "diff" alone is ambiguous (unix diff, git diff) — always qualify as **History diff** in this context
- "lock" was avoided for the mutex term because the implementation is a directory, not a file — **Mutex** describes the concept regardless of implementation

## Example dialogue

> **Dev:** "The user opens ctrl-r and there are 30 new commands since last time — what happens?"
> **Domain expert:** "The **History diff** is 30, below the threshold, so **Eager** kicks in — colorizes the 30 new entries, updates the **Cache**, and serves everything colored to fzf."

> **Dev:** "What if they haven't used ctrl-r in a week and there are 500 new commands?"
> **Domain expert:** "The **History diff** is 500, above the threshold, so **Lazy** is used — the 500 entries are shown raw on top of the existing **Cache**, and after fzf exits, a background process acquires the **Mutex** and rebuilds the **Cache** with full colorization."
