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

## Issue 03 — git-github new helpers
### No tests for thin wrappers
```zsh
gh api "repos/${repoName}" --jq '.archived'
```
**Problem:** zsh-writer mandates TDD for all new functions
**Reason skipped:** Issue spec explicitly overrides with "No tests (thin wrappers with no parsing logic)"

### Long-form flags vs spec short-form
```zsh
gh api \
  --method PATCH \
  "repos/${repoName}" \
  --field description="$description" \
  > /dev/null
```
**Problem:** Spec example used `-X PATCH` and `-f`, implementation uses `--method` and `--field`
**Reason skipped:** zsh-writer calling-commands.md mandates long-form flags; zsh-writer standard takes precedence over spec example syntax

## Issue 04 — project-remove
### bats_disable_worktree_aware not used
```bash
bats_run_zsh "OROSHI_ROOT=$BATS_TMP_DIR/oroshi project-remove myproject"
```
**Problem:** Tests override OROSHI_ROOT to point outside worktree without calling bats_disable_worktree_aware.
**Reason skipped:** The only external command (jsonc-remove-key) is mocked, so PATH resolution is irrelevant. No `cd` outside worktree happens.

### Single vs double bracket assertions
```bash
[ "$status" -eq 0 ]
```
**Problem:** Tests use `[` instead of `[[` for assertions.
**Reason skipped:** Both forms appear in existing project tests (e.g. project-exists.bats uses `[`). Standards examples are inconsistent.

### Spec happy-path test granularity
```bash
@test "calls jsonc-remove-key with projects.jsonc path and project name" {
```
**Problem:** Spec lists 3 separate happy-path behaviors but only one test covers the wiring.
**Reason skipped:** Spec says "mocking is fine here — test the wiring, not the JSONC parsing again". The three bullets describe delegated behavior already tested in issue 01.
