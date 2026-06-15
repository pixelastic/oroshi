## TLDR

Create `src/filetypes.json`, `filetypes-build`, and `dist/filetypes.zsh` — the new pipeline replacing the old ZSH source + flat env vars.

## What to build

**`src/filetypes.json`** — Human-editable source. Top-level keys are group names. Each group has:
- `"color"` — symbolic key resolved against `COLORS[]` (e.g. `"amber"`)
- `"icon"` — symbolic key resolved against `ICONS[]` (e.g. `"filetype-text"`)
- `"bold"` — optional, defaults to false
- `"patterns"` — array of plain strings (extension shorthand) or objects:
  - `{ "extension": "js", "color": "yellow", "icon": "filetype-js" }` — extension with overrides
  - `{ "filename": "Dockerfile" }` — exact filename match, optionally with overrides

JSON formatting: each group key on its own line; within a group, `color`/`icon`/`bold`/`patterns`
each on their own line; pattern objects written inline (no internal line breaks).

The `unknown` group is not included.

**`filetypes-build`** — ZSH script. Sources `dist/colors.zsh` (populates `COLORS[]`) and
`icons.zsh` (populates `ICONS[]`). Reads `src/filetypes.json` via `jq`. For each group and
each pattern, resolves color key → ANSI value via `COLORS[]` and icon key → glyph via `ICONS[]`.
Writes `dist/filetypes.zsh`.

**`dist/filetypes.zsh`** — Generated. Declares `typeset -gA FILETYPES` then populates:
- Per-extension: `FILETYPES[md:pattern]`, `FILETYPES[md:color]`, `FILETYPES[md:icon]`,
  `FILETYPES[md:bold]`, `FILETYPES[md:group]`
- Per-group: `FILETYPES[image:color]`, `FILETYPES[image:icon]`, `FILETYPES[image:bold]`
- Keys are lowercase; separator is `:`
- Exact filename patterns (e.g. `.gitignore`) are lowercased and dots converted to underscores
  for the key (e.g. `_gitignore`)

## Behavioral Tests

**Build output — extension entry:**
- Running the build with a minimal fixture JSON produces `FILETYPES[md:color]` with the resolved ANSI code
- Running the build produces `FILETYPES[md:pattern]` set to `*.md`
- Running the build produces `FILETYPES[md:group]` set to the group name
- Running the build produces `FILETYPES[md:icon]` set to the resolved glyph
- Running the build produces `FILETYPES[md:bold]` set to `0` when not specified

**Build output — filename entry:**
- A `{ "filename": ".gitignore" }` pattern produces `FILETYPES[_gitignore:pattern]` set to `.gitignore`

**Build output — override entry:**
- An extension object with `"color"` override uses the override color, not the group color
- An extension object with `"icon"` override uses the override icon, not the group icon

**Build output — group entry:**
- Running the build produces `FILETYPES[image:color]` with the group's resolved ANSI code
- Running the build produces `FILETYPES[image:icon]` with the group's resolved glyph

## Acceptance criteria

- [ ] `src/filetypes.json` contains all 11 groups and all existing patterns from `filetypes-list.zsh`
- [ ] `filetypes-build` runs without error and produces `dist/filetypes.zsh`
- [ ] `dist/filetypes.zsh` contains `typeset -gA FILETYPES` as its first declaration
- [ ] All per-extension keys present with correct values
- [ ] All per-group keys present with correct values
- [ ] Bats tests pass
