## TLDR

Update `json-get` with a well-defined API: `--input file` or stdin, newline-separated arrays, correct exit codes.

## What to build

Replace the current arity-based input detection (`[[ -p /dev/stdin ]]`) with an explicit `--input <filepath>` flag. When `--input` is omitted, read from stdin as before.

Change array output from comma-separated to one element per line, auto-detected from the JSON type — no caller flag needed.

Add correct exit code semantics:
- Exit 0 + empty output when the key is absent or null
- Exit 1 when the input is not valid JSON
- Exit 0 + value for all successful reads

Key path syntax stays unchanged: full jq path syntax (e.g. `.commands.rejected`, `.preToolUse.Bash.askedCommands`).

## Behavioral Tests

- read scalar from file: `--input` flag, returns value on stdout, exits 0
- read scalar from stdin: piped JSON, returns same value, exits 0
- read array: each element on its own line, exits 0
- absent key: produces no output, exits 0
- null value: produces no output, exits 0
- invalid JSON: exits 1 with no stdout

## Acceptance criteria

- [ ] `json-get --input file.json '.key'` reads from file
- [ ] `print -r -- "$json" | json-get '.key'` reads from stdin
- [ ] Array values returned one element per line
- [ ] Absent or null key returns empty output and exits 0
- [ ] Invalid JSON input exits 1
- [ ] Existing `compdef.zsh` reference requires no change (it's a completion list entry, not a functional call)
