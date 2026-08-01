## TLDR

Create `helper-list-raw` autoload function — scans both helper directories, extracts descriptions, filters via `fzf --filter`, outputs structured data.

## What to build

New autoload function at `tools/term/zsh/config/functions/autoload/misc/helper-list-raw`.

Behavior:
- Requires at least 1 argument (exit with error if none)
- Join all arguments with space as the fzf query
- Scan `$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/` and `$OROSHI_ROOT/scripts/bin/` using `find -type f`, excluding paths containing `__`
- For each file, extract the helper name (basename) and description
- Description extraction via internal `_extract_description` function: if line 1 starts with `#!` (shebang), read line 2; otherwise read line 1. Strip leading `# `. Empty string if no description found.
- Pipe all `name` lines through `fzf --filter="$query"` to get fuzzy-matched, ranked results
- For each matched name, output: `name▮description▮filepath` (absolute path)

Follow existing patterns:
- `setopt local_options err_return`
- Local variables with `local var="$(...)"`
- Return early on missing args
- Long-form flags for external commands

## Behavioral Tests

**Argument validation:**
- "exits with error when called with no arguments"

**Output format:**
- "outputs 3 fields separated by ▮"
- "first field is the helper name"
- "third field is an absolute filepath"

**Filtering:**
- "returns results for a known helper keyword"
- "returns empty output for a nonsense keyword"
- "matches regardless of keyword order"

## Acceptance criteria

- [ ] Function loads and runs without error
- [ ] At least 1 argument required
- [ ] Scans both autoload/ and scripts/bin/
- [ ] Excludes `__*` directories
- [ ] Output format: `name▮description▮filepath`
- [ ] Filepath is absolute
- [ ] Fuzzy matching via `fzf --filter`
- [ ] All bats tests pass
