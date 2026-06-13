## Problem Statement

Running `vws` tab-completion shows a broken header: white text with a dangling `}` instead of a colored "Worktrees" header. The same issue affects every other `compdef` completion function — all 36 files use pre-refactor color variable names (`$COLOR_ALIAS_*`, `$COLOR_WHITE`, `$COLOR_BLACK`, `$COLOR_GRAY_2`) and hardcoded Nerd Font glyphs that no longer exist or render incorrectly.

## Solution

Migrate all completion header calls across all `compdef` files to use the current naming conventions: the `$COLORS[key]` associative array for colors, `$ICONS[key]` for icon glyphs, and explicit `colors-load-definitions` + `icons-load-definitions` calls at the top of each function. Add placeholder icon keys to `icons.zsh` for concepts that currently lack a dedicated entry.

## User Stories

1. As a shell user, I want `vws` tab-completion to show a properly colored "Worktrees" header, so that I can visually distinguish the completion group at a glance.
2. As a shell user, I want all git completion headers (branches, tags, remotes, submodules, worktrees, files) to render with their correct colors and icons, so that each group is instantly recognizable.
3. As a shell user, I want all Docker completion headers to render correctly with color and an icon, so that image and container groups are visually differentiated.
4. As a shell user, I want all Yarn/Node completion headers to render correctly, so that scripts, dependencies, links, and binaries are visually organized.
5. As a shell user, I want pip, bats, make, SSH, jump, skill, plan, image-resize, and audio-stream completion headers to render correctly with color and an icon placeholder, so that all completion groups are visually consistent.
6. As a developer, I want all `$ICONS[key]` references to be backed by an entry in `icons.zsh`, so that missing glyphs do not silently produce empty strings.
7. As a developer, I want `colors-load-definitions` and `icons-load-definitions` called exactly once at the top of each completion function, so that the associative arrays are available in scope and duplicate calls are eliminated.
8. As a developer, I want new icon placeholders to use the literal string `X` until proper Nerd Font glyphs are chosen, so that the icon framework is wired up and glyphs can be filled in later without structural changes.

## Implementation Decisions

- **Color system**: All `$COLOR_ALIAS_FOO` references migrate to `$COLORS[semantic-key]` following the existing naming pattern (e.g. `COLOR_ALIAS_GIT_WORKTREE` → `$COLORS[git-worktree]`). Foreground shorthands map as: `COLOR_WHITE` → `$COLORS[white]`, `COLOR_BLACK` → `$COLORS[black]`, `COLOR_GRAY_2` → `$COLORS[gray-2]`.
- **Ambiguous mapping — yarn-link-local**: `COLOR_ALIAS_YARN_LINK_LOCAL` maps to `$COLORS[yarn-link-workspace]` (no `yarn-link-local` key exists; workspace is the semantic equivalent for local links).
- **Ambiguous mapping — yarn-link-global**: `COLOR_ALIAS_YARN_LINK_GLOBAL` maps to `$COLORS[yarn-package-global]`.
- **Icon system**: All hardcoded Nerd Font glyphs in header labels are replaced with `$ICONS[key]` references. Files that previously had no icon in their header label receive one. Files that already used `$ICONS[key]` are unchanged in that regard.
- **New icon keys** (added to `icons.zsh` with placeholder value `X`): `docker-image`, `flag`, `jump`, `language-bats`, `make`, `plan`, `skill`, `ssh`, `video-stream-audio`.
- **Load-definitions calls**: Every completion function receives exactly one `colors-load-definitions` and one `icons-load-definitions` call at the top of the function body. Functions that previously called `icons-load-definitions` three times are deduplicated.
- **No structural changes**: Function signatures, argument handling, and `_describe`/`compadd` call patterns are preserved exactly. Only the header string and load-definitions calls change.

## Testing Decisions

No automated tests are written for this change. The completion files and `icons.zsh` are configuration artifacts — their correctness is verified by loading the shell and exercising tab-completion manually. Writing bats wrappers to assert file content would test the file, not the behavior, and is explicitly out of scope per project conventions.

## Out of Scope

- Choosing actual Nerd Font glyphs for the 9 new placeholder icon keys — the user will fill these in after the migration.
- Redesigning header label text (e.g. capitalisation, punctuation, spacing) beyond what is needed to incorporate the `$ICONS[key]` variable.
- Migrating any files outside `compdef/` or `icons.zsh`.
- Adding new completion functions or changing completion data sources.
- Updating `styling.zsh` (already uses `$COLORS[key]` correctly).

## Further Notes

The `completion-header` function signature is `completion-header <bgColor> <fgColor> <label>`. The background color argument receives the terminal color number stored in `$COLORS[key]`, not a hex value or name — the `%K{...}` prompt escape handles the rendering.
