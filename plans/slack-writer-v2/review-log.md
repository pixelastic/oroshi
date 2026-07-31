## Issue 01 — Vale install
### Install location mechanism
```zsh
ln --force --symbolic "${INSTALL_PATH}/${BINARY_NAME}" .
```
**Problem:** Spec says "downloads the Vale binary to `~/local/bin/vale`" but implementation uses `~/local/etc/vale/` + symlink.
**Reason skipped:** Follows established repo pattern (taplo, jq, etc. all use `~/local/etc/` + symlink to `~/local/bin/`). Functional outcome matches spec intent.

## Issue 02 — prose-lint
### `local` at script level
```zsh
local valeOutput=""
```
**Problem:** Reviewer questioned whether `local` should be used at script (non-function) scope vs UPPER_CASE without `local`.
**Reason skipped:** Prior art (`zsh-lint`) uses `local` at script level throughout. The variables doc says "Use `local` for all variables, even if not in a function". Consistent with codebase.

### No explicit empty guard on valeOutput
```zsh
local result="$(printf '%s' "$valeOutput" | jq --compact-output "$JQ_FILTER")"
```
**Problem:** Reviewer flagged that `valeOutput` could be empty and lacks an explicit guard.
**Reason skipped:** Vale returns `{}` for clean files (never empty string). jq's `[.[][]]` on `{}` produces `[]`, which is correct. No silent failure path exists.

## Issue 03 — slack-writer-end
### `local` in script-level code
```zsh
local input="$1"
```
**Problem:** `local` used outside a function in a standalone script; zsh-writer checklist says "script constants UPPER_CASE without `local`"
**Reason skipped:** `variables.md` explicitly endorses `local` even outside functions; prior art (`clipboard-write:8`) uses the same pattern; `input` is not a constant

## Issue 05 — Vale profile strategy
### HITL gate not verifiable from diff
**Problem:** Spec requires analysis presented to user and user approval before implementing
**Reason skipped:** HITL gate was satisfied in conversation — analysis presented, user chose option C

### write-good.ThereIs not in spec
**Problem:** Rule disabled but not explicitly named in spec's target rules
**Reason skipped:** Discussed with user as part of the suggestion-level analysis; included in the "disable everywhere" decision

### Pre-existing oroshi.NoContractions anomaly in blog.ini
```ini
oroshi.NoContractions = error
```
**Problem:** Set to `error` under `# Disabled` heading — inconsistent with section semantics
**Reason skipped:** Pre-existing, outside this diff's scope
