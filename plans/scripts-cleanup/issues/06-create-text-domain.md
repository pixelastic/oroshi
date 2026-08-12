## Create text/ domain for string-manipulation functions

### Rename + move existing autoloaded functions into text/

| Current (in misc/) | New name | Notes |
|---------------------|----------|-------|
| `trim` | `text-trim` | ~6 callers to update |
| `truncate-to-width` | `text-truncate` | Callers: table, complete-git-worktrees + tests |
| `remove-ansi` | `text-ansi-remove` | ~14 callers to update |

`colorize` and `echoerr` stay in misc/ (no rename).

### Migrate from scripts/bin/

| Script | New name | Notes |
|--------|----------|-------|
| `text/text-select-line` | `text-line-get` | 1 caller: bats-test-path |
| `ai/translate` | `translate` | Keep name, move to text/ domain |
| `ai/txt2slack` | `txt2slack` | Keep name, move to text/ domain |
