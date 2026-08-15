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

## Issue 02 — wav2txt-groq

### set -e vs setopt err_return
```zsh
set -e
```
**Problem:** Reviewer flagged `set -e` instead of `setopt local_options err_return`
**Reason skipped:** File is a `__lib/` script with shebang, not an autoloaded function — `set -e` matches the "For scripts" template

### if/else in main dispatch
```zsh
if isFileTooBig "$input"; then
  rawTranscription="$(splitAndTranscribe "$input")"
else
  rawTranscription="$(transcribeFile "$input")"
fi
```
**Problem:** Reviewer flagged if/else instead of return-early pattern
**Reason skipped:** Binary dispatch producing a value — neither branch is a guard condition

### groq.zsh not in diff
```zsh
source "$OROSHI_ROOT/private/config/term/zsh/local/${HOSTNAME}/groq.zsh"
```
**Problem:** Spec reviewer flagged groq.zsh as missing from diff
**Reason skipped:** Private submodule has its own commit cycle

### ${HOSTNAME} instead of hardcoded vorugal
```zsh
source "$OROSHI_ROOT/private/config/term/zsh/local/${HOSTNAME}/groq.zsh"
```
**Problem:** Spec says `vorugal/groq.zsh`, implementation uses `${HOSTNAME}`
**Reason skipped:** Follows existing wav2txt-openai convention, more portable

## Issue 03 — Model toggle groq icon

### Missing Usage comment in header
```zsh
# Toggle the model used by mic2txt
setopt local_options err_return
```
**Problem:** Missing `Usage:` comment block per zsh-writer header standard
**Reason skipped:** Pre-existing omission, not introduced by this diff

### No test for Argos panel icon display
**Problem:** Acceptance criterion "Argos panel displays Groq icon when model is groq" has no automated test
**Reason skipped:** Runtime/integration concern; Argos panel resolves icons dynamically via `mic2txt-model-${modelName}.svg` — file exists at correct path

### SVG is not actual Groq logo
```svg
<path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 3c1.66 0 3 1.34 3 3s-1.34 3-3 3-3-1.34-3-3 1.34-3 3-3zm-1 14v-2h-1v-4h4v4h-1v2h-2z" />
```
**Problem:** Spec says "Groq logo" but SVG is a generic shape
**Reason skipped:** Trademarked brand logo not reproducible; a distinctive panel indicator is sufficient
