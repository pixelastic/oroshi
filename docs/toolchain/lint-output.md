# Unified lint JSON output schema

The canonical output format all `{lang}-lint` scripts produce. A single schema
enables one NeoVim diagnostic parser and uniform display in
[`git-file-lint`](integration.md#git-file-lint).

```json
[
  {
    "file": "path/to/file",
    "code": "RULE_ID",
    "level": "error",
    "line": 1,
    "endLine": 1,
    "column": 1,
    "endColumn": 10,
    "message": "Description of the violation"
  }
]
```

## Fields

| Field | Type | Description |
|---|---|---|
| `file` | string | Path to the file containing the violation |
| `code` | string | Rule identifier from the underlying linter |
| `level` | string | Severity: `error`, `warning`, `info`, or `hint` |
| `line` | number | Start line (1-based) |
| `endLine` | number | End line (1-based) |
| `column` | number | Start column (1-based) |
| `endColumn` | number | End column (1-based) |
| `message` | string | Human-readable description of the violation |

## Level mapping to NeoVim severities

| Lint level | NeoVim severity |
|---|---|
| `error` | `ERROR` |
| `warning` / `warn` | `WARN` |
| `info` | `INFO` |
| `style` / `hint` | `HINT` |

When there are no violations, the output is an empty array (`[]`) or an empty
string.
