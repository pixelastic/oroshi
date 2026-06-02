## Problem Statement

Reading and writing JSON values in ZSH scripts requires calling `jq` directly each time, resulting in repeated boilerplate and inconsistent error handling across the codebase. The existing `json-get` function has an outdated API: it uses arity-based input detection (fragile, not extensible), returns arrays as comma-separated strings (breaks on values containing commas), and has no companion write function. Scripts like `preToolUse-Bash-helper.zsh` end up with multiple raw `jq` calls that could be replaced by clean, testable helpers.

## Solution

Update `json-get` with a well-defined API and create a new `json-set` function. Both follow the same input convention (`--input file` or stdin). `json-get` auto-detects arrays and returns them newline-separated. `json-set` writes a single key in-place without overwriting other keys, supporting string (default), number, and array value types. Update `preToolUse-Bash` and `preToolUse-Bash-helper.zsh` to use these helpers instead of raw `jq` calls.

## User Stories

1. As a ZSH script author, I want to read a scalar JSON value by key path from a file, so that I don't have to write raw `jq` boilerplate.
2. As a ZSH script author, I want to read a scalar JSON value by key path from piped input, so that I can compose `json-get` in pipelines.
3. As a ZSH script author, I want arrays returned one element per line, so that I can load them into a ZSH array with `${(@f)$(...)}` without worrying about commas or spaces in values.
4. As a ZSH script author, I want `json-get` to return empty output and exit 0 when a key is absent or null, so that I can test for absence with `[[ "$val" == "" ]]`.
5. As a ZSH script author, I want `json-get` to exit 1 when the input is not valid JSON, so that I can detect parse errors explicitly.
6. As a ZSH script author, I want to write a string value to a single key in a JSON file, so that other keys in the file are preserved.
7. As a ZSH script author, I want to write a number value to a single key with `--number`, so that the JSON type is correct for consumers that distinguish strings from numbers.
8. As a ZSH script author, I want to write an array value by piping newline-separated elements with `--array`, so that I can use ZSH arrays as the source without quoting hell.
9. As a ZSH script author, I want `json-set` to create the target file if it doesn't exist, so that I don't need to initialise it manually.
10. As a ZSH script author, I want `json-set` to create missing intermediate keys, so that I can write nested paths into a new file in one call.
11. As a consumer of `preToolUse-Bash-helper.zsh`, I want the hook to use `json-get` and `json-set` internally, so that the hook code is readable and consistent with the rest of the codebase.

## Implementation Decisions

### `json-get` (update)

- Input: `--input <filepath>` flag for file source; stdin if omitted
- Key path: single positional arg, full jq path syntax (e.g. `.commands.rejected`)
- Scalar output: printed as a single line
- Array output: one element per line (auto-detected from JSON type — no flag needed)
- Absent/null key: empty output, exit 0
- Invalid JSON: exit 1
- Known limitation: array elements that themselves contain newlines are not supported; callers needing that should use raw `jq`
- Only caller of current `json-get` outside the file itself is a `compdef.zsh` completion list entry (not a functional call) — API change is safe

### `json-set` (new)

- `--input <filepath>` is required (always writes to a file, modified in-place)
- Signature: `json-set --input <file> '<key>' [value]`
- If value arg is omitted, reads from stdin
- Default type: string (written as JSON string)
- `--number` flag: write value as JSON number
- `--array` flag: read newline-separated lines from stdin, write as JSON array
- File does not exist: created with `{}` as base before writing
- Modifies only the specified key — all other keys preserved (uses jq path assignment)

### Hook update

- `preToolUse-Bash-helper.zsh` (`markAsAsked`) replaces raw `jq` subshells with `json-get` and `json-set` calls
- `preToolUse-Bash` replaces raw `jq` subshells for parsing `inputCommand`, `sessionId`, and the `rejected` array with `json-get` calls

## Testing Decisions

Good tests cover observable behavior only: what goes in stdout, what the exit code is, and what the file contains after a write. Internal jq flags or implementation choices are not tested.

- **`json-get`**: tested with `bats_run_function`. Scenarios: scalar from file, scalar from stdin, array returns newline-separated, absent key (empty + exit 0), null value (empty + exit 0), invalid JSON (exit 1).
- **`json-set`**: tested with `bats_run_function`. Scenarios: write string, write number (`--number`), write array from stdin (`--array`), file created if absent, existing keys preserved after write, nested path created.
- No tests for the hook update — the existing `preToolUse-Bash.bats` behavioral tests already cover end-to-end behavior.
- Prior art: `tools/term/zsh/config/functions/autoload/git/directory/__tests__/` — same bats helper pattern, `bats_run_function` approach.

## Out of Scope

- Array elements containing newlines (acceptable limitation of the newline-separated convention)
- `json-delete` — removing a key
- Reading multiple keys in one invocation
- Boolean and null value types in `json-set`
- Streaming / JSONL support
- `--number` is in scope; all other non-string scalar types are out of scope

## Further Notes

The symmetry between `json-get` and `json-set` is intentional: `json-get` on an array key returns newline-separated lines; `json-set --array` reads newline-separated lines and writes a JSON array. This makes round-tripping an array through a ZSH variable natural:

```zsh
local -a tags=(${(@f)$(json-get --input file.json '.tags')})
tags+=("new-tag")
printf '%s\n' "${tags[@]}" | json-set --input file.json '.tags' --array
```
