## Issue 03 — Docker completions

### icons.zsh — placeholder glyphs not `X`

**Problem:** Standards reviewer flagged that 9 new icon keys added in issue 01 have real Nerd Font glyphs rather than the `X` placeholder specified by the PRD.

**Reason skipped:** Finding is about issue 01 work, not issue 03. Out of scope.

---

### icons.zsh — `bats` vs `language-bats` key name

**Problem:** Issue 05 spec references `$ICONS[language-bats]` but the key added in issue 01 is `ICONS[bats]`. Latent breaking reference.

**Reason skipped:** Finding is about issue 01/05 work, not issue 03. Out of scope — should be addressed when issue 05 is implemented.

---

### `local header` — no empty guard

**Problem:** If `completion-header` returns empty, `_describe` fails silently.

**Reason skipped:** Judgement call with no documented standard requiring it; same pattern used in all migrated git completions (issue 02) without guards. Low severity.

---

### `_git-remotes` — double space in label

**Problem:** `" $ICONS[git-remote]  Remotes "` has two spaces before text; inconsistent with all other labels.

**Reason skipped:** Finding is about issue 02 work (`_git-remotes`), not issue 03. Out of scope.

---

## Issue 01 — Add placeholder icon keys

### zsh-lint disable comment not mentioned in spec

```zsh
# zsh-lint disable=missingIconsLoad
ICONS[kitty-tab-separator]="..."
```

**Problem:** Spec says "`zsh-lint` passes on `icons.zsh`", implying a clean pass without suppression.

**Reason skipped:** `icons.zsh` IS the definitions file sourced by `icons-load-definitions`. Adding `icons-load-definitions` at the top would cause infinite recursion — the function sources this file and its guard `((${#ICONS} > 0))` doesn't trigger mid-load. Suppression is the only correct fix. The spec's intent (lint passes) is satisfied.
