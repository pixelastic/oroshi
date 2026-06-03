## Issue 02 — json-set

### Spec: --array stdin consumption conflict
```zsh
jqValue="$(jq --raw-input --null-input '[inputs | select(length > 0)]')"
local newJson="$(jq "$jqArgType" v "$jqValue" "${jsonKey} = \$v" "$inputFile")"
```
**Problem:** Reviewer flagged that the second jq call might receive no stdin because the first consumed it.
**Reason skipped:** The second jq call passes `$inputFile` as a positional file argument — it reads from the file, not stdin. No conflict exists.

### Standards: test isolation (file-absent test)
```bats
@test "file absent: file is created with the written key" {
  bats_run_function json-set --input "$JSON_FILE" '.name' 'created'
```
**Problem:** Test doesn't assert the file didn't previously exist before the call.
**Reason skipped:** `bats_tmp_dir` creates a fresh isolated tmp dir per test; `$JSON_FILE` is defined in `setup()` and cannot exist at test start.
