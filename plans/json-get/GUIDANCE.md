## Guidance

### Domain vocabulary

- **`json-get`** — autoload function that reads a single key from JSON (file or stdin)
- **`json-set`** — autoload function that writes a single key into a JSON file in-place
- Key path syntax: jq path syntax, e.g. `.commands.rejected`, `.preToolUse.Bash.askedCommands`

### Files

- `json-get`: `tools/term/zsh/config/functions/autoload/json/json-get`
- `json-set`: `tools/term/zsh/config/functions/autoload/json/json-set` (new)
- Tests: `tools/term/zsh/config/functions/autoload/json/__tests__/`
- Hook: `tools/ai/claude/config/hooks/preToolUse-Bash`
- Hook helper: `tools/ai/claude/config/hooks/preToolUse-Bash-helper.zsh`

### Testing

- Run json function tests: `rtk bats tools/term/zsh/config/functions/autoload/json/__tests__/`
- Run hook tests: `rtk bats tools/ai/claude/config/hooks/__tests__/preToolUse-Bash.bats`
- Lint: `zshlint <filepath>`
- Tests use `bats_run_function` — see `tools/term/zsh/config/functions/autoload/git/directory/__tests__/git-directory-root.bats` as prior art

### Key constraints

- `json-get`: exit 0 + empty on absent/null key; exit 1 on invalid JSON
- `json-set`: `--input` is always required; `--array` reads newline-separated stdin
- No caller of `json-get` outside `compdef.zsh` (completion list only) — API change is safe
- Hook must always exit 0 — errors in helpers must not propagate

### API contracts (from design session)

```zsh
# json-get
json-get --input file.json '.key'          # from file
print -r -- "$json" | json-get '.key'      # from stdin

# json-set
json-set --input file.json '.key' 'value'           # string (default)
json-set --input file.json '.key' '42' --number     # number
printf '%s\n' "${arr[@]}" | json-set --input file.json '.key' --array  # array
```

## Discoveries

### Issue 02 — json-set

- `jq --raw-input --null-input '[inputs | select(length > 0)]'` converts newline-separated stdin to a JSON array and safely filters the empty trailing line produced by `<<<` herestrings
- Dynamic `--arg`/`--argjson` type flag: store flag name in a variable (`local jqArgType="--arg"`), pass as `jq "$jqArgType" v "$jqValue"` — jq accepts this cleanly
- The array-building jq and the file-writing jq don't conflict over stdin: the second jq reads from the positional `$inputFile` arg, not stdin

### Issue 01 — json-get update

- `${var:--}` (default to `-`) lets `cat --` fall back to stdin cleanly — eliminates the if/else data-loading branch entirely
- `select(. != null)` in jq produces no output for null/absent keys and exits 0 without `--exit-status`; safe with `err_return`
- `bats_run_function fn args <<< "stdin"` — the `<<<` stdin passes through `run` to the zsh subprocess correctly
