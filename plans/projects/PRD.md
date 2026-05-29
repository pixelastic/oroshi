## Problem Statement

The old project configuration system exports one environment variable per project attribute (`PROJECT_<KEY>_NAME`, `PROJECT_<KEY>_ICON`, `PROJECT_<KEY>_PATH`, etc.), producing ~1200 environment variables total. This is unmanageable: variable name collisions, character escaping constraints, and two parallel generation pipelines (`env-generate-projects` → `env/projects.zsh` + `env/projects.json`) running alongside the new system (`projects-build` → `dist/projects.zsh` + `dist/projects.json`).

Several consumers (ZSH functions, a Python Kitty module, a dead VimScript file) still read from the old system, preventing its removal.

## Solution

Migrate all remaining consumers to the new system — a ZSH global associative array `PROJECTS_V2` (loaded on demand via `projects-load-definitions`) for ZSH scripts, and `dist/projects.json` for non-ZSH tools — then delete the old system entirely and rename `PROJECTS_V2` to `PROJECTS`.

## User Stories

1. As a developer, I want `project-exists "aberlaas"` to return true without relying on flat environment variables, so that project lookups are consistent with the rest of the system.
2. As a developer, I want the yarn link prompt segment to display project icons using the associative array, so that it works without the old env var system loaded.
3. As a developer, I want jump autocompletion to display project icons using the associative array, so that it works without the old env var system loaded.
4. As a developer, I want `colors-refresh` to regenerate `dist/projects.zsh` and immediately reload `PROJECTS` in the current session, so that color changes are reflected without restarting the shell.
5. As a developer, I want `context-path` tests to pass using the bats mock pattern, so that they are not coupled to the old env var injection approach.
6. As a developer, I want the Kitty tab bar to read project colors and icons from `dist/projects.json`, so that it stays in sync with the single source of truth.
7. As a developer, I want all dead code referencing `PROJECTS_INDEX`, `PROJECT_<KEY>_*`, and the old JSON path removed, so that the codebase no longer contains two project data systems.
8. As a developer, I want `PROJECTS_V2` renamed to `PROJECTS` everywhere, so that the `_V2` migration suffix disappears once the old system is gone.
9. As a developer, I want the CONTEXT.md domain glossary updated to reference `dist/projects.zsh` and the associative array, so that the canonical definition of "Project" is accurate.

## Implementation Decisions

### Module 1 — ZSH consumers: `project-exists`, `yarn.zsh`, `complete-jumps`

- All three call `projects-load-definitions` at the top (idempotent, safe in prompt context).
- `project-exists` checks existence via the `:icon` key — a project is considered registered if and only if its icon entry is present in the associative array.
- `project-exists` no longer calls `project-key`; it uses the project name directly as the array key prefix.
- `yarn.zsh:oroshi-prompt-populate:yarn_link` reads the icon for each linked package name directly from the array.
- `complete-jumps` reads the icon for each mark name directly from the array.
- `project-key` is deleted — it only existed to convert names to the `PROJECT_<KEY>_*` env var format.

### Module 2 — `colors-refresh`

- After regenerating colors, call `projects-build` to regenerate `dist/projects.zsh`.
- Explicitly `unset PROJECTS` (previously `PROJECTS_V2`) to invalidate the stale in-memory array.
- Call `projects-load-definitions` immediately after to reload from the freshly generated file.
- The explicit unset + reload makes the intent readable: this script does a full refresh, not a lazy one.
- Remove the `env-generate-projects` call and the `source env/projects.zsh` line.

### Module 3 — `context-path.bats` rewrite

- The existing tests inject `PROJECTS_INDEX_BY_PATH` and `PROJECT_*` env vars into a `zsh -c` subshell. This no longer works because `context-path` → `context-root` → `project-name` now reads from `PROJECTS` (previously `PROJECTS_V2`).
- Rewrite following the `context-root.bats` pattern: use `bats_run_function`, mock `projects-load-definitions` to be a no-op, and populate `PROJECTS` directly inside each test's mock.

### Module 4 — Dead code deletion

Files and folders to delete in full:
- `project-key` autoload function
- The entire `fzf/projects/` autoload directory (contains `fzf-projects`, `fzf-projects-source`, `fzf-projects-options`, `fzf-projects-postprocess`, and their bats tests) — no keybinding triggers any of these
- `env-generate-projects` script
- `env/projects.zsh` generated file
- `env/projects.json` generated file
- `oroshi-old.vim` (dead VimScript using `PROJECTS_INDEX` and `PROJECT_*`)

### Module 5 — Kitty Python migration

- `initProjectList()` currently parses a flat dict (`PROJECT_<KEY>_NAME`, `PROJECT_<KEY>_ICON`, etc.) from `env/projects.json`.
- Replace with a direct iteration over the nested `dist/projects.json` structure: one key per project name, with `background.ansi`, `foreground.ansi`, `backgroundInactive.ansi`, and `icon` as subfields.
- `getCursorColor` already accepts an integer; `dist/projects.json` stores ANSI codes as integers — no conversion needed.
- The parsing logic becomes a simple loop, removing all the `_NAME`-suffix detection heuristics.

### Module 6 — Rename `PROJECTS_V2` → `PROJECTS` + CONTEXT.md update

- Global rename across all ZSH functions, scripts, tests, and the `dist/projects.zsh` generated file.
- Update `projects-build` to emit `PROJECTS` instead of `PROJECTS_V2`.
- Update `CONTEXT.md` definition of **Project** to reference the associative array in `dist/projects.zsh` instead of `PROJECT_<KEY>_*` env vars in `env/projects.zsh`.
- The `_V2` suffix was a migration guard to avoid collision with the old `PROJECTS_INDEX` variable; once deleted, the suffix has no purpose.

## Testing Decisions

Good tests check observable behavior through the public interface only — not internal variable names or implementation details. A test for `project-exists` should verify exit codes for known and unknown project names, not inspect how the array key is formed.

### `project-exists` — new bats tests

- No tests currently exist for this function.
- Test: returns exit 0 for a project name whose `:icon` key is present in `PROJECTS`.
- Test: returns exit 1 for an unknown project name.
- Test: returns exit 1 for a name whose entry exists but has no icon (e.g. a color-only definition like `dashboards`).
- Mock `projects-load-definitions` and populate `PROJECTS` directly, following the `context-root.bats` pattern.

### `context-path.bats` — rewrite existing tests

- Three existing tests; rewrite each to use `bats_run_function` + bats mock of `projects-load-definitions`.
- Populate `PROJECTS[$name:path]` inside each test's mock to replicate the fixture data the old env var injection was providing.
- Prior art: `context-root.bats`.

### Other modules — no tests

- `yarn.zsh`, `complete-jumps`, `colors-refresh`, Kitty Python, dead code deletion, and the rename do not require new tests.

## Out of Scope

- Changing the structure of `dist/projects.json` or `dist/projects.zsh` — the build pipeline (`projects-build`) is not modified.
- Adding new projects or modifying project color definitions.
- Migrating `context-root.bats` — it already uses the correct mock pattern.
- Any other consumers of `dist/projects.json` (Neovim statusline) — already using the new system.
- Removing `hideNameInPrompt` from projects where it is false — a separate cleanup, noted as a future simplification.

## Further Notes

- `:icon` is the canonical key for testing project existence. One project (`dashboards`) has no icon and is a color-only definition — `project-exists` correctly returns false for it.
- `projects-load-definitions` is intentionally idempotent and designed to be mocked in tests — this is why it exists as a separate function rather than being inlined.
- After this migration, the only remaining reference to project data outside of ZSH is `dist/projects.json`, read by Kitty. All ZSH consumers go through `projects-load-definitions`.
