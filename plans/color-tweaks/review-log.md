## Issue 01 — Filetype Icons

### Spec: glyphs copied but not removed from filetypes-list.zsh

```zsh
# filetypes-list.zsh still contains:
FILETYPE_GROUPS[text:icon]=" "
FILETYPE_GROUPS[script:icon]=" "
# ... (all original entries unchanged)
```

**Problem:** Spec says "move the Unicode glyphs", implying removal from the source file.

**Reason skipped:** Acceptance criteria make no mention of removing entries from `filetypes-list.zsh`. The GUIDANCE.md key file table lists `filetypes-list.zsh` as "Delete" — that deletion is scoped to a later issue. Both the source and `icons.zsh` can coexist until then.
