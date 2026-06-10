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

## Issue 02 — color-documentation-update

### Standards: gray/stone inline comments in FAMILIES block are "stale"
```js
// gray: slot 8 canonical = shade 5 (#4b5563) — dimmed text
{ name:'gray', start:200, ... }
// stone: slot 15 canonical = shade 5 (#57534e) — emphasis text
{ name:'stone', start:230, ... }
```
**Problem:** Reviewer flagged that these comments reference slot numbers now in ALT_COLORED, so they should have moved with the data.
**Reason skipped:** The comments document a cross-reference: each neutral family's shade 5 is *also* the terminal canonical at that slot. The relationship is accurate and intentional. The comment belongs near the family definition, not in ALT_COLORED.

### Spec: "All 21 palette families"
**Problem:** Spec says 21 families; the HTML (and colors.conf) has 20 named families.
**Reason skipped:** Pre-existing discrepancy in the spec wording. Actual slot layout has 20 families (6 primary + 6 secondary + 4 bonus + 4 neutral). The "21" appears to be a spec typo.

## Issue 03 — colors-build-new-algorithm

### Spec: "no key matching ANSI slots 16-31"
```bats
@test "dist/colors.json contains no entries for gap slots 16-19" {
  run jq '[to_entries[] | select(.value.ansi >= 16 and .value.ansi <= 19)] | length' ...
  [ "$output" = "0" ]
}
```
**Problem:** Spec says "slots 16-31" but test only checks 16-19.
**Reason skipped:** GUIDANCE Discovery #01 explicitly corrects the spec wording: "correct intent is slots 16-19 only — new red family starts at slot 20." Slots 20-31 are valid palette entries (red-0 through red-1).

### Spec: "21 families × 10 shades = 210 palette entries"
**Problem:** Spec says 210 entries; implementation and test use 200 (20 families).
**Reason skipped:** Pre-existing spec typo — the slot table in the same spec lists exactly 20 families. Implementation is consistent with the slot table, not the summary count.
