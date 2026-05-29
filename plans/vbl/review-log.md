## Issue 03 — Integrate new columns branch list

### `--with-icon` removed from git-date-colorize / git-commit-colorize
```zsh
local displayDate="$(git-date-colorize "$relativeTime")"
local displayCommit="$(git-commit-colorize "$commitHash")"
```
**Problem:** Reviewer flagged as potential regression vs original `--with-icon` usage.
**Reason skipped:** User intentionally simplified output format.

### git-branch-list-raw.bats test 2 failure (pre-existing)
```
not ok 2 branch line: name▮hash▮remote▮ref▮ahead▮behind▮date▮message▮
```
**Problem:** Test expects trailing `▮` after message field; format changed in issue 02.
**Reason skipped:** Pre-existing failure from issue 02, not in scope for issue 03.

## Issue 02 — split-ahead-behind-raw

### Spec reviewer: should use `%(upstream:ahead)` / `%(upstream:behind)` git atoms
```zsh
gitBranchFormat+="%(upstream:track)▮"         # [ahead 4, behind 1]
```
**Problem:** Spec says "replace with `%(upstream:ahead)` and `%(upstream:behind)` fields" but implementation keeps `%(upstream:track)` and parses with sed.
**Reason skipped:** `%(upstream:ahead)` and `%(upstream:behind)` are not valid format atoms in git 2.43 (`fatal: unrecognized %(upstream) argument: ahead`). The sed-parsing approach is the only viable implementation on this git version.

### Spec reviewer: empty strings for no-upstream branches violate "0 or positive integer"
**Problem:** Fields 5–6 are empty strings when a branch has no upstream, but spec says "numeric ahead count (0 or positive integer)".
**Reason skipped:** Empty means "no upstream set" — semantically distinct from "0 ahead". Consumers can check field 3 (remoteName) to distinguish. The spec acceptance criteria BATS tests only cover the tracked-branch case.

### Standards reviewer: `setopt local_options err_return` missing in `git-branch-list-raw`
**Problem:** `header.md` standard requires autoloaded functions to open with `setopt local_options err_return`.
**Reason skipped:** The function pre-existed without `setopt`; zshlint produced no violation; adding it is out of scope for this issue's minimal-change intent.

## Issue 01 — test-git-branch-list-raw

### Spec reviewer: `NF-1 -eq 7` should be `-eq 6`
```bash
count="$(awk -F'▮' '{print NF-1}' <<< "$line")"
[ "$count" -eq 7 ]
```
**Problem:** Reviewer argued 7 fields → 6 separators → `-eq 6`.
**Reason skipped:** Format terminates each field with `▮` (not separates). 7 fields → 7 `▮` terminators → `NF=8` in awk → `NF-1=7`. Correct.

### Spec reviewer: shape assertions weaker than fixture data
**Problem:** Tests check generic format shape rather than exact output values like worktree tests do.
**Reason skipped:** Issue 01 explicitly locks down format shape (field count, non-empty checks). Fixture-level assertions are out of scope for a regression-guard issue.
