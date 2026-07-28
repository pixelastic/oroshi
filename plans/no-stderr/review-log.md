## Issue 01 — echoerr function
### setopt local_options err_return contradicts spec
```zsh
setopt local_options err_return
```
**Problem:** Spec says "no `setopt err_return` — nothing can fail in an echo" but the line is present.
**Reason skipped:** Linter rule `missingErrReturn` mandates it on all autoloaded functions; removing it fails lint. Acceptance criteria requires lint-clean, so linter wins.

## Issue 02 — useEchoerr lint rule
### zsh-lint disable placement inside function body
```zsh
  # zsh-lint disable=useEchoerr
  local msg='Use `echoerr` instead of `echo ... >&2`'
```
**Problem:** Inline `zsh-lint disable=useEchoerr` inside function body is unique among rule files
**Reason skipped:** It's a different directive than shellcheck; must be inline to suppress the self-referencing violation on the msg line. Matches the same pattern in rule-no-or-guard.zsh line 7-8.
