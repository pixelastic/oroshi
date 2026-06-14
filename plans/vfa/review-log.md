## Issue 02 — bulk-color-variable-substitution

### Icon glyph extraction (5 option files + icons.zsh)
```zsh
local promptPrefix="$(colorize " $ICONS[fzf-commands] Commands " $COLORS[black] $COLORS[function])"
# + ICONS[fzf-commands]="x" in icons.zsh (+ 3 similar entries)
```
**Problem:** Spec says "mechanical variable substitution" only; icon extraction not mentioned.
**Reason skipped:** Explicitly requested by user mid-session. Follows pattern from issue 01.

### `packageDescriptionText` rename in `fzf-packages-apt-preview`
```zsh
local packageDescriptionText="${(F)packageDescription}"
colorize "${packageDescriptionText}" $COLORS[comment]
```
**Problem:** Out of spec scope.
**Reason skipped:** Required to fix pre-existing lint violation 2178. Per project memory, touched files must fix pre-existing lint errors.

---

## Issue 01 — fix-vfa-git-stageable-options

### ICONS[git-stageable]="x" is a placeholder, not a real glyph

```zsh
ICONS[git-stageable]="x"
```

**Problem:** Both reviewers flagged that `"x"` is ASCII, not a Unicode glyph. Every other icon in `icons.zsh` is a real glyph, and the rendered prompt will show a literal `x` instead of an icon.

**Reason skipped:** User explicitly instructed: "si tu ne trouves pas d'icônes qui sont déjà bien nommées par rapport à ça, tu en ajoutes des nouvelles si tu leur mets la variable x comme valeur." The `"x"` placeholder is intentional — the real glyph must be filled in manually.
