## Issue 01 — echoerr function
### setopt local_options err_return contradicts spec
```zsh
setopt local_options err_return
```
**Problem:** Spec says "no `setopt err_return` — nothing can fail in an echo" but the line is present.
**Reason skipped:** Linter rule `missingErrReturn` mandates it on all autoloaded functions; removing it fails lint. Acceptance criteria requires lint-clean, so linter wins.
