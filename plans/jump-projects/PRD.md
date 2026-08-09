## Problem Statement

The user navigates directories using two systems: **M** (mark) creates symlinks in a marks directory, and **J** (jump) cd's to a marked directory with autocompletion. However, the user also maintains a rich `projects.jsonc` config (~200 projects) with paths, icons, and colors. Today, `J` only suggests manually marked directories — the user has to remember to mark each project. The project list already knows about all projects and their paths, but this knowledge isn't used for navigation.

## Solution

Unify jump targets so that `J` autocompletion suggests **all projects from projects.jsonc** plus **manually marked directories**. Rename the underlying functions to a consistent `mark-*` naming convention (`mark-jump`, `mark-create`, `mark-delete`, `mark-list`, `mark-list-raw`) while preserving the short aliases (`j`, `m`, `mR`, `ml`). Move the marks directory from `~/.marks/` to `$OROSHI_TMP_FOLDER/marks`. Split completion so `mark-delete` only suggests actual marks, not projects.

## User Stories

1. As a developer, I want `j <tab>` to suggest all my projects and marks, so that I can jump to any project without manually marking it first
2. As a developer, I want `j myproject` to cd into the project directory even if I never ran `m` in it, so that navigation is frictionless
3. As a developer, I want projects to take priority over marks when names collide, so that the canonical project path always wins
4. As a developer, I want `m` to still create manual marks for arbitrary directories not in projects.jsonc, so that I can bookmark non-project dirs
5. As a developer, I want `m` to warn me when I mark a directory that already has a project entry, so that I avoid creating redundant marks
6. As a developer, I want `mR <tab>` to only suggest actual marks (not projects), so that I don't try to delete something that isn't a symlink
7. As a developer, I want `ml` to display my marks with colors, so that the output is readable
8. As a developer, I want a one-time cleanup script to remove marks that duplicate project entries, so that I start clean
9. As a developer, I want the marks directory to live in `$OROSHI_TMP_FOLDER/marks` instead of `~/.marks/`, so that it follows the dotfiles convention for runtime state
10. As a developer, I want the underlying functions named `mark-*` so that they form a discoverable, consistent domain
11. As a developer, I want completion descriptions to show the project icon when available and the resolved path otherwise, so that I can identify targets at a glance

## Implementation Decisions

- **Naming convention**: All functions use the `mark-` prefix. Aliases (`j`, `m`, `mR`, `ml`) preserved for muscle memory.
- **Function locations**: All `mark-*` autoloaded functions live in `misc/mark/` subdirectory under the autoload tree.
- **`mark-list-raw` output format**: `name▮path` using the `▮` separator, consistent with other `*-list-raw` functions in the codebase (e.g., `helper-list-raw`).
- **`mark-list-raw` scope**: Only lists real marks (symlinks in `$MARKPATH`), not projects. `complete-jumps` is responsible for merging in project entries.
- **`MARKPATH` location**: Moves from `$HOME/.marks` to `$OROSHI_TMP_FOLDER/marks`.
- **Priority**: When a name exists as both a mark and a project, `mark-jump` resolves via PROJECTS first, then falls back to marks.
- **`mark-jump` tilde expansion**: Project paths stored as `~/local/www/...` require `${~var}` expansion in ZSH to resolve the tilde.
- **Completion split**: `_jumps` compdef for `j`/`mark-jump` (marks + projects via `complete-jumps`). New `_marks` compdef for `mR`/`mark-delete` (marks only via `complete-marks`).
- **No visual distinction**: Marks and projects appear in one unified completion group. Project entries show their icon; plain marks show the resolved path.
- **`mark-create` warning**: When the target directory matches a project path, print a warning but still create the mark.
- **`mark-delete`**: Stays symlink-only. No project awareness needed.
- **Old scripts deleted**: `scripts/bin/mark` and `scripts/bin/unmark` are removed, replaced by autoloaded `mark-create` and `mark-delete`.
- **Alias file renamed**: `jump.zsh` becomes `mark.zsh`.

## Testing Decisions

- Test external behavior via BATS, mocking `$MARKPATH` with temp dirs and `PROJECTS` array with test data.
- Prior art: `misc/__tests__/helper-list-raw.bats` — same pattern of mocking directories and checking output format.
- **Tested modules**:
  - `mark-list-raw` — output format, empty dir, multiple marks
  - `mark-jump` — project resolution, mark fallback, missing target error, tilde expansion
  - `mark-create` — symlink creation, project warning output, default name from dirname
  - `mark-delete` — symlink removal, missing mark error
  - `complete-jumps` — merged marks + projects output, deduplication (projects win)
  - `complete-marks` — marks-only output
- **Not tested**: `_jumps`/`_marks` compdef wrappers (thin), `mark.zsh` aliases (config), `mark-list` (thin colored wrapper)

## Out of Scope

- Adding marks to `projects.jsonc` — marks stay as symlinks
- Modifying the `projects-build` pipeline or `projects.jsonc` schema
- Changing how `PROJECTS` array is loaded or structured
- FZF integration for jump selection
- Nested/hierarchical marks

## Further Notes

- The one-time cleanup script compares each symlink in `$MARKPATH` against `PROJECTS[name:path]` and removes matches. Should be run interactively with confirmation.
- Projects without a `path` key in `projects.jsonc` (15 out of 107) are excluded from jump targets — this is correct since they have no navigable directory.
- The `ml` alias changes from `ls $MARKPATH` to `mark-list`, which calls `mark-list-raw` and formats with colors using `colorize` and `table`.
