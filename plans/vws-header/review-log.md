## Issue 01 — Add placeholder icon keys

### zsh-lint disable comment not mentioned in spec

```zsh
# zsh-lint disable=missingIconsLoad
ICONS[kitty-tab-separator]="..."
```

**Problem:** Spec says "`zsh-lint` passes on `icons.zsh`", implying a clean pass without suppression.

**Reason skipped:** `icons.zsh` IS the definitions file sourced by `icons-load-definitions`. Adding `icons-load-definitions` at the top would cause infinite recursion — the function sources this file and its guard `((${#ICONS} > 0))` doesn't trigger mid-load. Suppression is the only correct fix. The spec's intent (lint passes) is satisfied.
