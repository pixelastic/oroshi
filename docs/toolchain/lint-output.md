# Lint output formats

All `{lang}-lint` scripts support two output modes: a default stylish format for
terminal use, and a `--json` format for machine consumers (NeoVim, agents).

---

## Default — stylish

Violations are grouped by file. Each file appears as a header line, followed by
indented violations with aligned columns.

```
path/to/file.zsh
  3:10  error  Missing double quotes around variable    SC2086
  7:1   warn   Variable is referenced but not assigned  SC2154

path/to/other.zsh
  12:5  error  Unreachable code after return  custom/unreachable
```

Format per violation line: `line:column  level  message  code`.

When there are no violations, output is empty (no output, exit 0).

---

## `--json` — unified JSON

```json
[
  {
    "file": "path/to/file",
    "code": "RULE_ID",
    "level": "error",
    "line": 1,
    "endLine": 1,
    "column": 1,
    "endColumn": 5,
    "message": "Description of the violation"
  }
]
```

### Fields

| Field | Type | Description |
|---|---|---|
| `file` | string | Absolute path to the file containing the violation |
| `code` | string (optional) | Rule identifier from the underlying linter |
| `level` | string | Severity: `error`, `warn`, `info`, or `hint` |
| `line` | number | Start line of the violation (1-based) |
| `endLine` | number | End line of the violation (1-based). Falls back to `line` when the underlying linter has no range info |
| `column` | number | Start column of the violation (1-based) |
| `endColumn` | number | End column of the violation (1-based). Falls back to `column` when the underlying linter has no range info |
| `message` | string | Human-readable description of the violation |


The four `level` values map directly to NeoVim's `vim.diagnostic.severity`
constants (`ERROR`, `WARN`, `INFO`, `HINT`) — no conversion needed.

When there are no violations, the output is an empty array (`[]`).
