## Issue 01 — fzf-options-files helper

### Missing setopt local_options err_return in function body

```zsh
fzf-options-files() {
  local scriptName="$1"
  ...
}
```

**Problem:** Reviewer flagged missing `setopt local_options err_return` inside the function body.
**Reason skipped:** This applies to autoloaded functions only (per memory). This is a sourced lib file — none of the other lib files in `__lib/` use this guard (`fzf-options-base.zsh`, `fzf-options-prompt-directory.zsh`, `fzf-source-files.zsh` all omit it).

### Single-bracket [ "$status" -eq 0 ] in tests

```bats
[ "$status" -eq 0 ]
```

**Problem:** Reviewer flagged inconsistency with `[[` style used in the same file.
**Reason skipped:** Established codebase pattern — all existing test files use `[ "$status" -eq 0 ]` for status checks (verified in ctrl-p.bats, fzf-options-prompt-label.bats, etc.).
