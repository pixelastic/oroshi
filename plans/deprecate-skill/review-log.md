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

## Issue 02 — npm domain helpers
### Missing tests for thin wrappers
```zsh
npm view "$packageName" &>/dev/null
```
**Problem:** Standards agent flagged 4 of 5 helpers as untested
**Reason skipped:** Spec explicitly states "Thin wrappers have no tests (just exit code forwarding)"

### Mock doesn't filter by npm subcommand
```bash
npm() {
  echo '{"name":"old-pkg","deprecated":"This package is no longer maintained"}'
}
bats_mock npm
```
**Problem:** Mock intercepts all `npm` calls regardless of subcommand
**Reason skipped:** London school mocking — mock the immediate collaborator, not its argument dispatch

### jq dependency not in spec
```zsh
echo "$jsonOutput" | jq --exit-status '.deprecated' &>/dev/null
```
**Problem:** `jq` is an external dependency not mentioned in the spec
**Reason skipped:** Spec says "checks for deprecated field" without prescribing how; `jq` is the idiomatic JSON tool per CLAUDE.md
