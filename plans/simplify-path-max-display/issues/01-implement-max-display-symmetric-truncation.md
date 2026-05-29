## TLDR

Replace `maxDepth` with `maxDisplay`: symmetric truncation + full test rewrite.

## What to build

`simplify-path` currently truncates any path deeper than `maxDepth` to a fixed `first … penultimate last` pattern. Replace this with a `maxDisplay` parameter that controls exactly how many segments are shown, filled symmetrically from both ends around a central `…`.

The internal variable `maxDepth` is renamed `maxDisplay`. The positional interface (`$2`) is unchanged — no callers need updating.

**Truncation formula** (from PRD prototype):
- `left = ⌊(maxDisplay - 1) / 2⌋` segments from the path start
- `…` in the middle
- `right = maxDisplay - 1 - left` segments from the path end

**Clamping**: values below 4 are silently set to 4 before any computation.

**No truncation** when `depth ≤ maxDisplay`.

Examples:
- `maxDisplay=4`: `first … penultimate last`
- `maxDisplay=5`: `first second … penultimate last`
- `maxDisplay=6`: `first second … antepenultimate penultimate last`

The bats test suite is fully rewritten to cover: default behaviour, custom `maxDisplay` (5 and 6), clamping (values < 4), slash preservation, home substitution, and `--reply` flag.

## Acceptance criteria

- [ ] Path longer than `maxDisplay` (default 4) is truncated to `first … penultimate last`
- [ ] `maxDisplay=5` on a 6-segment path yields `first second … penultimate last`
- [ ] `maxDisplay=6` on a 7-segment path yields `first second … antepenultimate penultimate last`
- [ ] Path at exactly `maxDisplay` segments is unchanged
- [ ] Path shorter than `maxDisplay` is unchanged
- [ ] `maxDisplay=3` and `maxDisplay=2` silently fall back to 4
- [ ] Leading slash preserved after truncation
- [ ] Trailing slash preserved after truncation
- [ ] `$HOME` prefix replaced with `~` before truncation
- [ ] `--reply` writes result to `$REPLY` with no echo
- [ ] All bats tests pass
