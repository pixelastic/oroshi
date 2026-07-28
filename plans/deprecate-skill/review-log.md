## Issue 01 — jsonc-remove-key
### Wrong directory
```
scripts/bin/json/jsonc-remove-key.js
```
**Problem:** Spec says `tools/_languages/json/`, files are in `scripts/bin/json/`
**Reason skipped:** `scripts/bin/json/` is on PATH and follows `json2json5` precedent; `tools/_languages/json/` only contains install scripts for system tools

### Plain Error instead of firostError
```javascript
throw new Error(`File not found: ${filePath}`);
```
**Problem:** Uses plain `Error` instead of `firostError` with structured code property
**Reason skipped:** CLI script writes to stderr and exits — structured error codes add no value for a tool that outputs to terminal
