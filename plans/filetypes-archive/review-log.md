## Issue 03 — Wire archives compdef

### compdef-glob-from-group.zsh placement

```zsh
source ${0:A:h}/compdef-glob-from-group.zsh
```

**Problem:** Standards reviewer flagged that `compdef-glob-from-group.zsh` lives in `completion/` instead of `functions/autoload/`, making the `source`+`unfunction` pattern a workaround for misplacement.
**Reason skipped:** Intentional design from issue 02, documented in GUIDANCE.md: "File lives in `completion/` (not autoload), so it needs a `.zsh` extension to pass `is-zsh` / `zsh-lint`". The `source`+`unfunction` pattern is the documented convention for this directory (see `styling.zsh`).
