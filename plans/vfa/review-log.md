## Issue 01 — fix-vfa-git-stageable-options

### ICONS[git-stageable]="x" is a placeholder, not a real glyph

```zsh
ICONS[git-stageable]="x"
```

**Problem:** Both reviewers flagged that `"x"` is ASCII, not a Unicode glyph. Every other icon in `icons.zsh` is a real glyph, and the rendered prompt will show a literal `x` instead of an icon.

**Reason skipped:** User explicitly instructed: "si tu ne trouves pas d'icônes qui sont déjà bien nommées par rapport à ça, tu en ajoutes des nouvelles si tu leur mets la variable x comme valeur." The `"x"` placeholder is intentional — the real glyph must be filled in manually.
