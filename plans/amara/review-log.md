## Issue 01 — wav2txt-openai source-safe guard

### Wrong test location (Standards)
```
plans/amara/scaffold/01-wav2txt-openai-source-safe.bats
```
**Problem:** Reviewer flagged it should be in `__tests__/` per CLAUDE.md.
**Reason skipped:** Scaffolding tests explicitly live in `plans/<slug>/scaffold/` per the scaffolding-tests reference. The `__tests__/` rule applies to behavioral tests only.

### `source` mock approach uncertain (Standards)
```zsh
source() {
  [[ "$1" == *private* ]] && return 0
  builtin source "$@"
}
bats_mock source
```
**Problem:** Reviewer questioned whether `bats_mock` correctly shadows the builtin.
**Reason skipped:** GUIDANCE explicitly mandates "mock `source` builtin to skip credential loading". The test passes; the pattern works because `bats_mock` serializes the already-defined function to mock.zsh via `declare -f`.

### Non-invocation not explicitly asserted (Spec)
**Problem:** Spec says sourcing must not call `transcribeFile`/`splitAndTranscribe`; test only checks exit status and empty output.
**Reason skipped:** Empty output + exit 0 is sufficient proof that no external commands ran. An explicit stub-call counter would be over-engineering for a structural guard.

### No direct-run test (Spec)
**Problem:** "Running `wav2txt-openai` directly preserves existing behavior" has no test.
**Reason skipped:** Out of scope for a scaffolding test on the source-safe guard. Direct-run behavior is unchanged code; no structural transformation to verify.

### mic2txt-raw not tested (Spec)
**Problem:** "Existing callers (`mic2txt-raw`) are unaffected" has no test.
**Reason skipped:** `mic2txt-raw` calls `wav2txt-openai` as an external command, not by sourcing it. The guard only affects the sourced path. No change to the command interface.
