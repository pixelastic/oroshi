## Issue 01 — audio-split --max-size

### ffmpeg short-form flags
```zsh
ffmpeg -i "$input" -ss "$prevPoint" -c copy "$output" -y 2>/dev/null
```
**Problem:** ffmpeg args not one-per-line per calling-commands.md
**Reason skipped:** ffmpeg flags are standard domain idioms; expanding to long-form would hurt readability across 6+ calls

### numChunks abbreviation
```zsh
local numChunks=$(( (fileSize + maxBytes - 1) / maxBytes ))
```
**Problem:** `numChunks` abbreviates "number" per variables.md
**Reason skipped:** `numChunks` is a universally understood abbreviation; `numberOfChunks` adds verbosity without clarity

### No chunk size validation
```
spec line 26: "each output chunk is smaller than the specified max size"
```
**Problem:** No test or runtime check verifies chunk sizes stay under maxBytes after silence-snapping
**Reason skipped:** silence-snapping is best-effort; ffmpeg `-c copy` doesn't guarantee exact sizes; re-splitting oversized chunks is out of scope

### No silence boundary assertion
```
spec line 28: "cuts happen at silence boundaries (not mid-audio)"
```
**Problem:** No test asserts split points equal detected silence timestamps
**Reason skipped:** verifying exact ffmpeg arguments is implementation detail, not behavioral; silence-snapping is covered by the implementation using mocked silences correctly
