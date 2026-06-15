## Problem Statement

Filetype group definitions are currently maintained as a hand-written ZSH associative array
(`filetypes-list.zsh`), which is then compiled into ~200 flat environment variables exported
into the shell (`env/filetypes.zsh`). This pollutes the shell environment with hundreds of
`FILETYPE_*` variables, making every child process inherit unnecessary data. The source format
is also inconsistent with how colors and projects are defined (JSON source → build script →
`dist/` ZSH array), and icons are embedded as raw Unicode glyphs rather than being referenced
by symbolic key from the shared `ICONS[]` registry.

## Solution

Replace the ZSH source + flat-env-var pipeline with a JSON-source + build-script + assoc-array
pipeline, consistent with the colors and projects theming subsystems.

- A human-editable `src/filetypes.json` defines filetype groups with symbolic color and icon keys.
- A `filetypes-build` ZSH script resolves those keys against the existing `COLORS[]` and
  `ICONS[]` arrays and generates `dist/filetypes.zsh`.
- `dist/filetypes.zsh` populates a single `FILETYPES[]` associative array (no env var exports).
- A new `filetypes-load-definitions` autoload function provides a no-op-if-already-loaded
  entry point for all consumers, making the array mockable in tests.
- A new `zsh-lint` custom rule enforces that every file accessing `FILETYPES[]` calls
  `filetypes-load-definitions` first.
- Filetype icons are moved into a dedicated `filetype-*` section of `icons.zsh`, referenced by
  key in `filetypes.json`.

## User Stories

1. As a developer editing filetype definitions, I want a JSON source file so that I can add or
   modify filetype groups in a structured, readable format.
2. As a developer, I want filetype colors referenced by semantic name (e.g. `"amber"`) so that
   I can change a palette color without touching filetype definitions.
3. As a developer, I want filetype icons referenced by key (e.g. `"filetype-text"`) so that I
   can update an icon glyph in one place (`icons.zsh`) without touching filetype definitions.
4. As a developer, I want a new `filetype-*` icon group in `icons.zsh` so that filetype icons
   are co-located with all other named icons.
5. As a developer, I want extension patterns defined as plain strings and exact filename patterns
   defined as `{ "filename": "Dockerfile" }` objects so that both match types are explicit and
   unambiguous in the JSON.
6. As a developer, I want per-extension overrides (color, icon, bold) inline within the group's
   pattern list as `{ "extension": "js", "color": "yellow", "icon": "filetype-js" }` objects so
   that overrides are co-located with their parent group.
7. As a developer, I want a `filetypes-build` script so that I can regenerate `dist/filetypes.zsh`
   after editing `src/filetypes.json`.
8. As a developer, I want `dist/filetypes.zsh` to populate a single `FILETYPES[]` assoc array
   (not flat env vars) so that the shell environment is not polluted.
9. As a developer, I want assoc array keys to use `:` as separator and lowercase extension names
   (e.g. `FILETYPES[md:color]`) so that the convention matches `COLORS[]` and `PROJECTS[]`.
10. As a developer, I want group-level keys (`FILETYPES[image:color]`) alongside per-extension
    keys so that consumers can reference the generic color or icon for a whole group.
11. As a developer, I want `filetypes-load-definitions` to be a no-op when `FILETYPES[]` is
    already populated so that it can be safely called multiple times and easily mocked in tests.
12. As a developer writing a ZSH function that needs filetype data, I want to call
    `filetypes-load-definitions` at the top of my function so that the function is
    self-sufficient and does not rely on the array being pre-loaded by a parent script.
13. As a developer, I want a `zsh-lint` custom rule (`missingFiletypesLoad`) so that any file
    accessing `FILETYPES[]` without first calling `filetypes-load-definitions` is flagged as a
    lint error.
14. As a developer, I want `ls.zsh` updated to iterate `FILETYPES[]` keys filtered on `:pattern`
    suffix so that `LS_COLORS` is built without a separate index variable.
15. As a developer, I want `filetype-group` updated to look up `FILETYPES[$ext:group]` so that
    it returns the group name for a given file using the new assoc array.
16. As a developer, I want `img-display` updated to reference `FILETYPES[image:color]` so that
    it uses the group-level color from the assoc array.
17. As a developer, I want `fzf-fs-shared-preview-header` updated to reference
    `FILETYPES[$ext:color]` and `FILETYPES[$ext:icon]` so that file previews use the new array.
18. As a developer, I want the old `env/filetypes.zsh` source line removed from `theming/index.zsh`
    so that filetypes are no longer eagerly loaded at shell startup.
19. As a developer, I want `src/filetypes-list.zsh`, `src/env-generate-filetypes`, and
    `env/filetypes.zsh` deleted so that the old pipeline no longer exists.

## Implementation Decisions

### JSON source format

Each top-level key is a group name (e.g. `"text"`, `"script"`). Each group has:
- `"color"` — symbolic color key resolved against `COLORS[]` (e.g. `"amber"`, `"violet"`)
- `"icon"` — symbolic icon key resolved against `ICONS[]` (e.g. `"filetype-text"`)
- `"bold"` — optional boolean, defaults to false
- `"patterns"` — array of either:
  - a plain string: treated as a file extension (`"md"` → matches `*.md`)
  - an object with `"extension"` or `"filename"` key, plus optional `"color"`, `"icon"`, `"bold"` overrides

The `unknown` group (previously a placeholder) is removed entirely.

JSON formatting: each top-level key on its own line; within a group, each of `color`, `icon`,
`bold`, `patterns` on its own line; pattern objects written inline (no internal line breaks).

### `FILETYPES[]` assoc array key structure

Keys use `:` as separator, lowercase throughout:

- Per-extension: `FILETYPES[md:color]`, `FILETYPES[md:icon]`, `FILETYPES[md:group]`,
  `FILETYPES[md:bold]`, `FILETYPES[md:pattern]`
- Per-group: `FILETYPES[image:color]`, `FILETYPES[image:icon]`, `FILETYPES[image:bold]`

Extension names derived from exact-filename patterns use the filename lowercased and
dots/dashes converted to underscores (e.g. `.gitignore` → `_gitignore`).

Group names and extension names do not collide — confirmed by grep across existing definitions.

### `filetypes-build` script

Written in ZSH. Sources `dist/colors.zsh` to populate `COLORS[]` and sources `icons.zsh` to
populate `ICONS[]`. Reads `src/filetypes.json` via `jq`. Resolves each `color` key to its ANSI
value (`COLORS[$color]`) and each `icon` key to its glyph (`ICONS[$icon]`). Writes
`dist/filetypes.zsh` with a `typeset -gA FILETYPES` declaration followed by all key assignments.

### `filetypes-load-definitions`

Same pattern as `colors-load-definitions` and `icons-load-definitions`. Guard: return early
if `${#FILETYPES}` is already greater than zero. Otherwise, source `dist/filetypes.zsh`.

### `zsh-lint` rule `missingFiletypesLoad`

Same structure as `rule-missing-colors-load.zsh`. Triggers on any line containing
`$FILETYPES[` (excluding comment lines) when `filetypes-load-definitions` is absent from the
file. Registered in `zsh-lint-custom.zsh` alongside the existing load-definition rules.

### Consumer updates

Each consumer (`ls.zsh`, `filetype-group`, `img-display`, `fzf-fs-shared-preview-header`) adds
a call to `filetypes-load-definitions` at the top and replaces `${(P)${:-FILETYPE_*_*}}`
dynamic variable lookups with direct `$FILETYPES[$key]` subscripts using lowercase extension
names (`${ext:l}`).

`ls.zsh` replaces iteration over `${=FILETYPES_INDEX}` with iteration over `${(k)FILETYPES}`
filtered to keys ending in `:pattern`.

`theming/index.zsh` removes the `source env/filetypes.zsh` line and adds nothing — lazy loading
via `filetypes-load-definitions` is sufficient.

### Icons

A new `filetype-*` section is added to `icons.zsh`, containing one entry per group
(e.g. `ICONS[filetype-text]`) plus one entry per per-extension icon override
(e.g. `ICONS[filetype-js]`, `ICONS[filetype-vue]`, `ICONS[filetype-go]`). The Unicode glyphs
are moved from `filetypes-list.zsh` into these entries.

## Testing Decisions

Good tests verify observable output, not internal implementation. For build scripts, the
observable output is the content of the generated file. For lint rules, the observable output
is the list of violations reported. For autoload functions, the observable output is whether
the array is populated after the call, and whether a second call is truly a no-op.

### Modules with tests

- **`filetypes-build`** — bats test: runs the build script against a minimal fixture JSON,
  verifies that `dist/filetypes.zsh` contains the expected `FILETYPES[md:color]` etc. entries.
  Prior art: `__tests__/colors-build.bats`, `__tests__/projects-build.bats`.

- **`filetypes-load-definitions`** — bats test: verifies the array is empty before the call,
  populated after, and that a second call does not re-source the file.
  Prior art: `__tests__/colors-load-definitions.bats`, `__tests__/icons-load-definitions.bats`.

- **`rule-missing-filetypes-load`** — bats test: verifies the rule fires on a file that uses
  `$FILETYPES[` without `filetypes-load-definitions`, and does not fire when the call is present.
  Prior art: `__tests__/rule-missing-colors-load.bats`, `__tests__/rule-missing-icons-load.bats`.

### Modules without new tests

Consumer updates (`ls.zsh`, `filetype-group`, `img-display`, `fzf-fs-shared-preview-header`)
do not get new tests. If existing tests for these files break due to test-helper refactors,
they will be fixed on a case-by-case basis.

## Out of Scope

- Generating `dist/filetypes.json` — no non-ZSH consumers currently need filetype data.
- NeoVim or Kitty integration — neither consumes `FILETYPES[]` today.
- Adding new filetype groups or extensions — this PRD only refactors the pipeline.
- An `icons-build` script or `dist/icons.json` — icons remain a ZSH-only source file.

## Further Notes

The `unknown` group existed solely to generate `FILETYPE_GROUP_UNKNOWN_*` env vars; no
consumer references those vars. It is removed without replacement.

The existing `${(P)${:-FILETYPE_*}}` dynamic variable lookup pattern in consumers is notably
complex; the new `$FILETYPES[$key]` subscript syntax is a meaningful readability improvement
for those files.
