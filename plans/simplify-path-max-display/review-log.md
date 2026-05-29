## Issue 01 — maxDisplay symmetric truncation

### Missing `setopt local_options errexit`
```zsh
zmodload zsh/zutil
zparseopts -E -D \
  -reply=flagReply
```
**Problem:** Header standard requires `setopt local_options errexit` in autoloaded functions.
**Reason skipped:** Pre-existing omission, not introduced by this diff. Out of scope for this issue.

### Bash-style array slice syntax
~~Résolu~~ — zshlint faux positif (code 2054) corrigé en amont. Syntaxe native `$array[1,$n]` / `$array[-$n,-1]` utilisée finalement.
