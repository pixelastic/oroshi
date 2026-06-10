# Review log

## Issue 01 — colors-conf-new-layout

### Spec: "Slots 16-31 have no color definitions"
```
# 20-29: red (TW v1) {{{
color20  #250f0f
...
color29  #742a2a
```
**Problem:** Acceptance criterion says slots 16-31 have no color entries, but new red family occupies 20-29.
**Reason skipped:** This is a spec wording typo. The authoritative scaffolding test checks slots 16-19 only, which is consistent with the guidance layout where palette families start at slot 20.

### Standards: shade 9 = shade 8 for TW v1 families (duplicate values)
```
color28  #742a2a
color29  #742a2a
```
**Problem:** Shade 9 duplicates shade 8 for all TW v1 families (red/green/yellow/blue/purple), which could look like a copy-paste error.
**Reason skipped:** Addressed with a comment in the colorscheme header block clarifying "TW v1 families: shades 1-8 = TW v1 200-900; shade 9 = TW v1 900 (no v1 950)."
