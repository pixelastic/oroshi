## TLDR

Create `json-set`, a new autoload function that writes a single key into a JSON file in-place without overwriting other keys.

## What to build

`json-set --input <file> '<key>' [value]`

- `--input <filepath>` is required — always writes to a file, modified in-place
- Key path: jq path syntax, single positional arg (e.g. `.preToolUse.Bash.askedCommands`)
- Value: third positional arg; if omitted, read from stdin
- Default type: string (written as a JSON string)
- `--number` flag: write value as a JSON number
- `--array` flag: read newline-separated lines from stdin, write as a JSON array
- File does not exist: create it with `{}` as base before writing
- Modifies only the specified key — all other keys in the file are preserved

The symmetry with `json-get` is intentional: `json-get` returns arrays one element per line; `json-set --array` reads them the same way. Round-tripping an array through a ZSH variable is natural:

```zsh
# from prototype — encodes the round-trip contract
local -a tags=(${(@f)$(json-get --input file.json '.tags')})
tags+=("new-tag")
printf '%s\n' "${tags[@]}" | json-set --input file.json '.tags' --array
```

## Behavioral Tests

- write string: target key holds the new string value, all other keys unchanged, exits 0
- write number: `--number` flag, value stored as JSON number not string
- write array from stdin: `--array` flag, each stdin line becomes one array element in JSON
- file absent: target file is created and contains the written key in a valid JSON object
- nested path: intermediate keys are created when the path does not yet exist

## Acceptance criteria

- [ ] `json-set --input file.json '.name' 'tim'` writes `"tim"` as a JSON string
- [ ] `json-set --input file.json '.count' '42' --number` writes `42` as a JSON number
- [ ] `printf 'a\nb\n' | json-set --input file.json '.tags' --array` writes `["a","b"]`
- [ ] Value from stdin when third arg is omitted
- [ ] Non-target keys in the file are not modified
- [ ] File is created if it does not exist
- [ ] Nested key path created if intermediate keys are absent
- [ ] Lives in the same autoload `json/` directory as `json-get`
