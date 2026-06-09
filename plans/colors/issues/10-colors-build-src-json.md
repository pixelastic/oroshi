## TLDR

Extract the inline color definitions from `colors-build` into a `src/colors.json` file, separating data from logic — the same split already in place for projects.

## Motivation

`colors-build` currently mixes two concerns: the definitions of what colors exist (named colors, ranges, aliases) and the logic that builds `dist/colors.zsh` / `dist/colors.json`. Extracting the definitions into `src/colors.json` makes them easier to read and edit without touching the build script. It also eliminates the kebab-case transformation step: since the keys in `src/colors.json` are already kebab-case, `colors-build` can use them as-is.

## Prior art

`tools/term/zsh/config/theming/src/projects.json` + `projects-build` — identical split.

## What to build

### 1. Create `src/colors.json`

`tools/term/zsh/config/theming/src/colors.json`

Three sections, all keys kebab-case:

```json
{
  "namedColors": {
    "0":   "black",
    "1":   "red",
    "17":  "orange",
    "210": "dark-red",
    ...
  },
  "colorRanges": {
    "6":  "red",
    "7":  "green",
    "8":  "yellow",
    ...
  },
  "aliases": {
    "git-branch":  "orange",
    "directory":   "green",
    "success":     "green",
    ...
  }
}
```

Populate it with the exact same data currently hardcoded in `colors-build`, converting all names from `UPPERCASE_SNAKE` to `kebab-case` (e.g. `BLACK_LIGHT` → `black-light`, `GIT_BRANCH` → `git-branch`, `DARK_AMBER` → `dark-amber`).

### 2. Update `colors-build`

`tools/term/zsh/config/theming/colors-build`

- Add `local srcJson="${themingRoot}/src/colors.json"`
- Remove the three inline `typeset -A` blocks (`namedColors`, `colorRanges`, `aliasColors`)
- Load each section from `src/colors.json` into ZSH associative arrays using `jq`:
  ```zsh
  typeset -A namedColors
  while IFS=$'\t' read -r idx name; do
    namedColors[$idx]="$name"
  done < <(jq -r '.namedColors | to_entries[] | "\(.key)\t\(.value)"' "$srcJson")
  ```
  (same pattern for `colorRanges` and `aliases`)
- Remove the kebab conversion lines (`local kebabKey="${${(L)colorKey}//_/-}"`, `local kebabRawName=...`, `local kebabAliasName=...`) — the keys from `src/colors.json` are already kebab-case
- The rest of the logic (reading `kitty/colors.conf`, building `colorsByName`/`colorsByNameHexa`, generating dist files) stays unchanged

### 3. Update `colors-build.bats`

`tools/term/zsh/config/theming/__tests__/colors-build.bats`

- Add a minimal `src/colors.json` fixture in `setup()` (similar to how `projects-build.bats` creates `src/projects.json`):
  ```bash
  mkdir -p "$THEMING_ROOT/src"
  jq -n '{
    "namedColors": { "17": "orange" },
    "colorRanges": { "8": "yellow" },
    "aliases":     { "git-branch": "orange" }
  }' >"$THEMING_ROOT/src/colors.json"
  ```
- All existing test assertions stay unchanged

## Acceptance criteria

- [ ] `src/colors.json` exists with `namedColors`, `colorRanges`, and `aliases` sections, all keys kebab-case
- [ ] `colors-build` contains no hardcoded `namedColors`, `colorRanges`, or `aliasColors` definitions
- [ ] `colors-build` reads definitions from `src/colors.json` via `jq`
- [ ] No kebab conversion code remains in `colors-build` (keys are already kebab in the source JSON)
- [ ] `dist/colors.zsh` and `dist/colors.json` are regenerated and identical in content to before
- [ ] All `colors-build.bats` tests pass
