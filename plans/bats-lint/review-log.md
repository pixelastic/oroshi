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
