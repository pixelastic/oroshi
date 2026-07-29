## Issue 01 — Migrate branch scripts to autoload

### Flag test pattern in git-branch-prune
```zsh
local forceRun="0"
[[ $* =~ "-f" ]] && forceRun="1"
```
**Problem:** Reviewer flagged `== "0"` string comparison as inconsistent with `[[ $isXxx == "1" ]]` flag test pattern.
**Reason skipped:** `forceRun` is a manually-set string var, not a `${#flagXxx}` length value. The flag test convention applies to zparseopts-derived flags only.

### Scaffolding tests absent (spec review)
**Problem:** Spec reviewer reported scaffolding tests missing.
**Reason skipped:** False positive — tests exist at `plans/git-path-helpers/scaffold/01-migrate-branch-scripts-to-autoload.bats`. The reviewer didn't find the scaffold directory.
