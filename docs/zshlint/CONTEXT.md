# zshlint

A wrapper around shellcheck that lints ZSH files. Its output is consumed by both
NeoVim (for inline diagnostics) and AI agents (for automated fixes).

> This file will move to `scripts/bin/zsh/zshlint/CONTEXT.md` once the directory
> is created during implementation.

## Language

**Shellcheck Rule**: A built-in shellcheck check, identified by a `SC####` code.
Configured in `zshlint` via `--exclude`. Cannot be extended without recompiling shellcheck.
_Avoid_: "native rule", "shellcheck check"

**Custom Rule**: A ZSH function defined in a Lib File, identified by a `9####` code.
Scans a file for a style violation not covered by shellcheck. Outputs Rule Output lines
consumed by the Orchestrator.
_Avoid_: "custom check", "grep rule", "maison rule"

**Rule Output**: The `▮`-separated line a Custom Rule writes to stdout per violation.
Format: `file▮code▮level▮line▮message`. One line per violation, empty output = no violation.
_Avoid_: "rule result", "rule response"

**Orchestrator**: The main `zshlint` script. Sources all Lib Files at startup, runs
shellcheck, calls each Custom Rule function directly (no subshell), merges all results
into a single JSON array output.
_Avoid_: "zshlint script", "main script"

**Lib File**: A `.zsh` file in `__rules/` that defines exactly one Custom Rule function.
Not executable — sourced by the Orchestrator and by bats tests.
_Avoid_: "rule file", "helper file"

## Relationships

- The **Orchestrator** sources all **Lib Files** at startup, then calls each Custom Rule function directly (static list — comment a line to disable a rule)
- Each **Lib File** defines exactly one **Custom Rule** function
- Each **Custom Rule** outputs zero or more **Rule Output** lines to stdout
- The **Orchestrator** converts Rule Output lines → JSON objects, merges with shellcheck JSON → final output

## File structure

```
scripts/bin/zsh/zshlint/       ← in PATH via path.zsh **/ glob
  zshlint                      ← Orchestrator
  CONTEXT.md                   ← this file (final location)
  __rules/                     ← excluded from PATH (__ prefix)
    rule-no-grouped-locals.zsh
    rule-while-read.zsh
    ...
  __tests__/                   ← excluded from PATH (__ prefix), co-located with code
    rule-no-grouped-locals.bats
    rule-while-read.bats
    ...
```

## Rule Output format

```
file▮code▮level▮line▮message
```

- `file`: path to the scanned file (needed by AI agents)
- `code`: integer in `9####` range
- `level`: `error` | `warning` | `style`
- `line`: 1-based line number
- `message`: human-readable description

JSON defaults for unused fields: `column=1`, `endLine=line`, `endColumn=1`.

## Custom Rule naming

- Lib File: `__rules/rule-{slug}.zsh` (kebab-case slug)
- Function: `zshlintRule_{CamelCaseName}()` (namespace + camelCase)

## Custom Rule codes

| Code  | Function                        | Rule |
|-------|---------------------------------|------|
| 90001 | `zshlintRule_noGroupedLocals`   | No grouped `local` declarations |
| 90002 | `zshlintRule_localOrReturn`     | No `\|\|` chained on `local` line |
| 90003 | `zshlintRule_noExternalBasename`| Prefer `:t`/`:h`/`:a` over `$(basename/dirname/realpath)` |
| 90004 | `zshlintRule_noWhileRead`       | No `while read` loops |
| 90005 | `zshlintRule_noShift`           | No `shift` for arg parsing |
| 90006 | `zshlintRule_singleEqualsInTest`| Use `==` not `=` in `[[ ]]` |
| 90007 | `zshlintRule_elseSmell`         | `else` blocks suggest missing return-early |

## Testing

Tests are co-located in `__tests__/`, one `.bats` file per Custom Rule.
Each test loads the global helper via relative path, sources its Lib File directly,
and calls the function — no subshell overhead, no dependency on the full Orchestrator.

```bash
load '../../../__tests__/helper'   # relative path to scripts/bin/__tests__/helper

@test "détecte un local groupé" {
  local file="$(bats_tmp)/test.zsh"
  echo 'local a b c' > "$file"
  run zsh -c "source '${BATS_TEST_DIRNAME}/../__rules/rule-no-grouped-locals.zsh'; zshlintRule_noGroupedLocals '$file'"
  [[ "$output" == *"90001"* ]]
}
```
