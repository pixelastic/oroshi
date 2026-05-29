## Problem Statement

`simplify-path` uses a single `maxDepth` parameter that conflates two concerns: it is both the threshold at which truncation kicks in and the number of visible segments. The fixed truncation pattern always shows exactly `first … penultimate last` (4 segments), regardless of the value passed. There is no way to display more context (e.g. also show the second directory from the root) without changing the implementation.

## Solution

Replace `maxDepth` with a single `maxDisplay` parameter. When the path depth exceeds `maxDisplay`, the path is truncated to exactly `maxDisplay` visible segments. The `…` ellipsis always occupies one slot in the middle; the remaining slots are filled symmetrically from both ends of the path (left side gets ⌊(maxDisplay-1)/2⌋ segments, right side gets the rest).

Default value remains 4. Values below 4 are silently clamped to 4.

Examples:
- `maxDisplay=4`: `first … penultimate last`
- `maxDisplay=5`: `first second … penultimate last`
- `maxDisplay=6`: `first second … antepenultimate penultimate last`
- `maxDisplay=7`: `first second third … antepenultimate penultimate last`

## User Stories

1. As a shell user, I want the prompt path to be truncated to 4 segments by default, so that short paths display in full and long paths remain readable without any config.
2. As a shell user, I want to pass a custom `maxDisplay` value, so that I can see more directory context when navigating deep trees.
3. As a shell user with `maxDisplay=5`, I want to see `first second … penultimate last`, so that I get one extra segment of context on both the root and the leaf side.
4. As a shell user with `maxDisplay=6`, I want to see `first second … antepenultimate penultimate last`, so that the extra segments are added symmetrically.
5. As a shell user, I want a path at exactly `maxDisplay` segments to display unchanged (no ellipsis), so that truncation only triggers when it is truly needed.
6. As a shell user, I want a path shorter than `maxDisplay` to display unchanged, so that short paths are never modified.
7. As a shell user, I want passing `maxDisplay=2` or `maxDisplay=3` to silently fall back to 4, so that the function never produces an unreadable one- or two-segment output.
8. As a shell user, I want leading slashes to be preserved after truncation, so that absolute paths remain visually correct.
9. As a shell user, I want trailing slashes to be preserved after truncation, so that directory-style paths remain visually correct.
10. As a shell user, I want `$HOME` to be replaced with `~` before truncation, so that home-rooted paths remain compact.
11. As a caller using `--reply`, I want the result written to `$REPLY` with no echo, so that I can capture the value without a subshell.
12. As a caller using `--reply`, I want the same truncation logic as the echo path, so that both output modes are consistent.

## Implementation Decisions

- **Rename parameter**: the internal variable `maxDepth` is renamed to `maxDisplay` to reflect its new semantics. The positional argument interface (`$2`) is unchanged — no new flags are added.
- **Clamping**: if `maxDisplay` < 4, it is silently set to 4 before any computation.
- **Truncation formula**: when `depth > maxDisplay`, the output is built as:
  - `left = ⌊(maxDisplay - 1) / 2⌋` segments from the start of the array
  - `…` as a single middle element
  - `right = maxDisplay - 1 - left` segments from the end of the array
  - (integer division — no floating point, no rounding functions needed)
- **No truncation when `depth ≤ maxDisplay`**: the path is emitted as-is.
- **Slash handling and `~` substitution**: unchanged from the current implementation.
- **`--reply` flag**: unchanged from the current implementation.

## Testing Decisions

Good tests assert observable output for a given input; they do not inspect internal variable names or intermediate state.

The following cases must be covered:

**Default behaviour (no maxDisplay arg)**
- Path longer than 4 segments → truncated to `first … penultimate last`
- Path exactly 4 segments → unchanged
- Path shorter than 4 segments → unchanged
- Single segment → unchanged

**Custom maxDisplay**
- `maxDisplay=5`, path of 6 segments → `first second … penultimate last`
- `maxDisplay=6`, path of 7 segments → `first second … antepenultimate penultimate last`
- `maxDisplay=5`, path of exactly 5 segments → unchanged
- `maxDisplay=5`, path of 4 segments → unchanged

**Clamping**
- `maxDisplay=3` (below minimum) → behaves as `maxDisplay=4`
- `maxDisplay=2` (below minimum) → behaves as `maxDisplay=4`

**Slash preservation**
- Leading slash preserved after truncation
- Trailing slash preserved after truncation

**Home substitution**
- `$HOME`-prefixed path replaced with `~`

**`--reply` flag**
- `--reply` produces no echo output
- `--reply` writes the correct simplified path to `$REPLY`

Prior art: existing `simplify-path.bats` using `bats_run_function` helper — same style throughout.

## Out of Scope

- Adding a separate `--threshold` flag distinct from `maxDisplay` (decided: one parameter covers both concerns).
- Supporting `maxDisplay` values of 1, 2, or 3 (minimum is 4).
- Changing the ellipsis character from `…`.
- Modifying any callers of `simplify-path` (prompt, fzf helpers, statusline) — they all use the default and are unaffected.
- Renaming the positional argument in the public interface (it remains `$2`).
