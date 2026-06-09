## TLDR

Rename the `colors` associative array to `COLORS` and convert all keys from `UPPERCASE_SNAKE` to `kebab-case`, achieving a uniform convention across `COLORS`, `ICONS`, and `PROJECTS`.

## Motivation

`ICONS` and `PROJECTS` already follow UPPERCASE-array + kebab-key convention. `colors` was built with a different convention (lowercase array, UPPERCASE_SNAKE keys). This issue aligns `colors` to match, making paired usage symmetric:

```zsh
# Before
%F{$colors[GIT_BRANCH]}$ICONS[git-branch]%f

# After
%F{$COLORS[git-branch]}$ICONS[git-branch]%f
```

## Key transformation rule

Mechanical, no ambiguity: all underscores → hyphens, all characters lowercase.

```
UPPERCASE_SNAKE  →  kebab-case
GREEN_0          →  green-0
DARK_AMBER       →  dark-amber
BLACK_LIGHT      →  black-light
GIT_BRANCH       →  git-branch
SUCCESS          →  success
```

The `:hex` suffix is preserved as-is: `COLORS[git-branch:hex]`.

## What to build

### 1. `colors-build` — change key generation + array name

`tools/term/zsh/config/theming/colors-build`

- Output `typeset -gA COLORS` instead of `typeset -gA colors`
- When generating keys, apply: uppercase → lowercase, `_` → `-`
- Regenerate `dist/colors.zsh` and `dist/colors.json` by running the script

### 2. `colors-load-definitions` — update guard

`tools/term/zsh/config/functions/autoload/colors/colors-load-definitions`

- `((${#colors} > 0))` → `((${#COLORS} > 0))`

### 3. `colors-template-render` — update array references

`tools/term/zsh/config/functions/autoload/colors/colors-template-render`

- `${(k)colors}` → `${(k)COLORS}`
- `${colors[$key]}` → `${COLORS[$key]}`

### 4. Template source files — update placeholders to kebab

- `tools/git/git/config/src/gitconfig`
- `tools/cli/rg/config/src/rgrc.conf`
- `tools/cli/bat/config/src/oroshi.xml`

Replace all `{{UPPERCASE_SNAKE}}` and `{{UPPERCASE_SNAKE:hex}}` placeholders with their kebab equivalents.

### 5. Prompt + tool files (migrated in issue 06) — update lookups

In all files below, replace `$colors[KEY]` → `$COLORS[kebab-key]` and `${(l:2::0:)colors[KEY]}` → `${(l:2::0:)COLORS[kebab-key]}`:

**Prompt** (`tools/term/zsh/config/prompt/`): `exit-code.zsh`, `git.zsh`, `path.zsh`, `node.zsh`, `ruby.zsh`, `yarn.zsh`

**Tools** (`tools/term/zsh/config/tools/`): `fzf.zsh`, `ls.zsh`, `exa.zsh`, `nnn.zsh`, `zsh.zsh`

**Completion** (`tools/term/zsh/config/completion/`): `styling.zsh`

### 6. `projects-list.zsh` — update color value strings

`tools/term/zsh/config/theming/src/projects-list.zsh`

Color name strings stored as values (e.g., `"YELLOW_7"`, `"GRAY_9"`) must become kebab: `"yellow-7"`, `"gray-9"`.

### 7. Tests — update fixtures

`tools/term/zsh/config/functions/autoload/colors/__tests__/colors-template-render.bats`
`tools/term/zsh/config/theming/__tests__/projects-build.bats` (if any `colors[KEY]` references)

Update any `colors[KEY]` fixture references to `COLORS[kebab-key]`.

### 8. `GUIDANCE.md` — update contract

`plans/colors/GUIDANCE.md`

- Array access contract table: update all examples to `COLORS[kebab-key]`
- JSON shape example: update keys to kebab-case
- Migration pattern: update substitution targets

### 9. Issue 07 — update description

`plans/colors/issues/07-zsh-consumers-statusbar-misc.md`

Update all `$colors[NAME]` references in the issue description to `$COLORS[kebab-name]`.

## Acceptance criteria

- [ ] `dist/colors.zsh` declares `typeset -gA COLORS` with kebab keys
- [ ] `dist/colors.json` uses kebab keys: `{ "git-branch": { "ansi": 17, "hex": "..." } }`
- [ ] No `colors[` references remain anywhere (only `COLORS[`)
- [ ] No `UPPERCASE_SNAKE` keys in any `COLORS[...]` lookup
- [ ] Template placeholders are kebab: `{{git-branch}}`, `{{git-branch:hex}}`
- [ ] `colors-template-render.bats` passes
- [ ] Prompt renders correctly with colors (manual verification)
