## Issue 09 — zsh-lint-helper-refactor

### `setopt local_options err_return` missing in function bodies

```zsh
zsh-lint-shellcheck() {
  # no setopt err_return
  ...
}
```

**Problem:** Standards reviewer flagged missing `setopt local_options err_return` in both new function bodies.
**Reason skipped:** The bats-lint prior art (`bats-lint-shellcheck.zsh`, `bats-lint-custom.zsh`) does not use it. These are sourced helpers, not autoload functions. Adding it would diverge from the established pattern.

### `local` at script scope flagged as violation

**Problem:** Standards reviewer flagged `local dir=`, `local -a input=()`, `local merged=` at script scope as a style violation.
**Reason skipped:** `zsh-writer/references/variables.md` explicitly says "Use `local` for all variables, even if not in a function." The reviewer was wrong.

### `_zshLintRulesDir` should be `_ZSH_LINT_RULES_DIR`

```zsh
_zshLintRulesDir="${0:A:h}/__rules"
```

**Problem:** Standards reviewer flagged naming — script-scope constants should be UPPER_CASE.
**Reason skipped:** Mirrors `_batsLintRulesDir` from `bats-lint-custom.zsh` exactly. Renaming would break the naming symmetry between the two linters.

### `_zshLintRulesDir` before vs after guard (spec contradiction)

**Problem:** Spec "What to build" says capture before the guard; implementation places it after.
**Reason skipped:** "Watch out" note and prior art both say after. The spec has an internal contradiction. After-guard placement is correct — it prevents namespace pollution when the function is mocked.

### `zsh-lint.bats` migration not in diff

**Problem:** Spec says "migrate orchestrator tests to use `bats_mock`".
**Reason skipped:** The existing `zsh-lint.bats` already uses `bats_mock` + `bats_run_script` for the mock-based tests. No actual migration was needed. Integration tests continue to work correctly with the refactored orchestrator.

## Issue 02 — bats-lint-custom

### Shell injection in test assertions

```bats
run bash -c "printf '%s' '$output' | jq 'type == \"array\"'"
run bash -c "jq 'length' <<< '$output'"
```

**Problem:** `$output` interpolated into single-quoted bash -c string; breaks if output contains single quotes.
**Reason skipped:** Same pattern used in zshlint-custom.bats (prior art). Fixture content is fully controlled and never contains single quotes. Fixing would diverge from prior art for no practical benefit.

### `col` vs `column` JSON field

**Problem:** Spec says `col`; implementation emits `column`/`endColumn` (mirroring zshlint-custom).
**Reason skipped:** GUIDANCE.md mandates mirroring zshlint-custom architecture exactly. zshlint uses `column`. Downstream tooling (NeoVim integration) already consumes zshlint's `column` field.

## Issue 01 — noRunZsh rule

### Output format corrected post-issue: aligned with zshlint

Format updated from `file▮line▮col▮code▮message` to `file▮code▮error▮line▮message` to match zshlint exactly. The spec's `line▮col▮code▮message` was incorrect — zshlint-custom parses `fields[1..4]` and NeoVim expects that layout. All tests still pass.

## Issue 03 — bats-lint-shellcheck

### `run zsh` instead of `bats_run_script`

```bats
run zsh "$BATS_LINT_SC" "$file"
```

**Problem:** Standards reviewer flagged `bats_run_script` as the prescribed helper for standalone scripts.
**Reason skipped:** Existing `bats-lint-custom.bats` uses `run zsh "$SCRIPT"` throughout (prior art). Diverging would create inconsistency with sibling tests in the same directory.

### UPPER_CASE for `excludedRules`

```zsh
local -a excludedRules=()
```

**Problem:** Reviewer flagged as constant, should be `EXCLUDED_RULES`.
**Reason skipped:** `excludedRules` is mutable (populated with `+=`), not a true constant. Prior art `zsh-lint-shellcheck` uses the same camelCase name. zshlint passes with no violation. SC2148 was also removed post-review — array is now empty since `--shell=bash` makes it unnecessary.
