## Issue 01 — fzf-js-test picker
### Three aliases to same script
```zsh
yrt fzf-js-test
yrtw fzf-js-test
yrtff fzf-js-test
```
**Problem:** Three keybinding aliases all resolve to the same script with no behavioral differentiation.
**Reason skipped:** Spec explicitly requires all three mappings.

### sort-filepaths addition
```zsh
fd ... | sort-filepaths
```
**Problem:** `sort-filepaths` pipe not mentioned in spec's fd command.
**Reason skipped:** Consistent with `fzf-source-files` prior art; harmless ordering improvement.

### Two-arg fzf-colorize-path
```zsh
fzf-colorize-path "$item" "${SEARCH_PATH}/${item}"
```
**Problem:** Reviewer unsure if two-argument call is correct.
**Reason skipped:** Matches `fzf-colorize-path` signature `(display-path, real-path)` and `fzf-source-files.zsh` usage.
