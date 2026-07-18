## Issue 02 — mic2txt-raw min-duration guard
### Tests use real /dev/shm path
```bash
TMP_FOLDER="/dev/shm/oroshi/mic2txt"
```
**Problem:** Tests write to production tmpfs path instead of isolated sandbox
**Reason skipped:** Same pattern as mic2txt-cancel.bats. Injecting env var override into prod code contradicts feedback_no_env_var_mocks.md.

### No guard on empty startTime
```zsh
local startTime="$(cat $startTimeFile)"
```
**Problem:** If START_TIME is missing/empty, arithmetic defaults to 0, skipping the guard
**Reason skipped:** `set -e` aborts on missing file. Empty file impossible — written by `echo $EPOCHREALTIME` in same script.

### cat vs $(<...) for file read
```zsh
local startTime="$(cat $startTimeFile)"
```
**Problem:** Should use `$(<$startTimeFile)` ZSH idiom
**Reason skipped:** Existing code on same file line 38 uses `cat $pidFile`. Consistency with surrounding code.

### Guard placement outside stopRecording
```zsh
local startTime="$(cat $startTimeFile)"
local elapsed=$(( EPOCHREALTIME - startTime ))
if (( elapsed < 2 )); then
  mic2txt-cancel
  exit 0
fi
```
**Problem:** Spec says "before the existing sleep 2" (inside stopRecording), but guard is before stopRecording call
**Reason skipped:** Spec intent is "recordings < 2s trigger mic2txt-cancel". mic2txt-cancel handles kill + cleanup + sound. Placing guard before stopRecording achieves this correctly.
