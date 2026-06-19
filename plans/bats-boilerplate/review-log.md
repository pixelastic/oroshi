## Issue 01 — Harden helper
### Redundant teardown() in helper.bats
```bash
teardown() {
  bats_cleanup
}
```
**Problem:** Now a no-op override of the identical default from helper.
**Reason skipped:** Intentional — mirrors the 120 existing files and validates the override model per acceptance criteria.

## Issue 07 — Fix projects-build path quoting
### bats_run_zsh source pattern not documented
```bash
bats_run_zsh "source '$script'"
```
**Problem:** Reviewer flagged `source` as an undocumented pattern for `bats_run_zsh`.
**Reason skipped:** `bats_run_zsh` takes a command string; `source '...'` is a valid zsh command. The file is created at runtime without +x, so sourcing is the correct approach.

### Tilde expansion decision undocumented in diff
```bash
[ "${lines[10]}" = '~/projects/full' ]
```
**Problem:** Reviewer noted the spec asked to verify downstream consumers, no evidence of check in diff.
**Reason skipped:** Verified against existing `projects-list.zsh` which stores literal `~/` in quoted paths — same convention. Noted in GUIDANCE.md discoveries.

### Cosmetic jq reformatting
```jq
($projectData.background |
  if . then (gsub("-[0-9]+$"; "") + "-dark")
  else null end) as $bgInactiveName |
```
**Problem:** Reformatting not requested by spec.
**Reason skipped:** Required by `commandTooLong` lint rule (max 100 chars). Not optional.
