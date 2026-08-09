## TLDR

Create `mark-list` — colored display of marks using `mark-list-raw`.

## What to build

Create `tools/term/zsh/config/functions/autoload/misc/mark/mark-list`:
1. Call `mark-list-raw` to get `name▮path` lines
2. If empty, return 0 silently
3. Parse each line, colorize name and path using `colorize` and `COLORS`
4. Output via `table`

Prior art: `helper-list` uses the same pattern — calls `helper-list-raw`, parses `▮` fields, colorizes, outputs via `table`.

## Behavioral Tests

**mark-list with marks:**
- outputs colored content (contains ANSI codes)

**mark-list with no marks:**
- outputs nothing, exits 0

## Acceptance criteria

- [ ] `misc/mark/mark-list` exists and is autoloadable
- [ ] Calls `mark-list-raw` internally
- [ ] Uses `colorize` and `table` for formatted output
- [ ] Silent on empty mark directory
- [ ] All behavioral tests pass
