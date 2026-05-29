## Problem Statement

The CTRL-O fzf widget for the `ralph` command surfaces plan directories, but the underlying functions are named after `ralph` (the consumer) instead of `plans` (what they represent). There is also no shared data source abstracted from the FZF layer, so the same list of plan directories cannot be reused by the zsh tab completion system. As a result, typing `ralph <TAB>` offers no completion at all.

## Solution

Extract a dedicated `plan-list-raw` helper that is the single source of truth for listing plan directories (direct subdirectories of `plans/` at git root). Rename the FZF widget family from `fzf-fs-directories-ralph-*` to `fzf-fs-directories-plans-*` and make the source delegate to `plan-list-raw`. Wire `plan-list-raw` into a new `complete-plans` / `_plans` compdef pair so that `ralph <TAB>` offers tab-completion with the same data.

## User Stories

1. As a developer, I want `ralph <TAB>` to show me all plans in the `plans/` directory, so that I don't have to remember or type paths manually.
2. As a developer, I want the CTRL-O fzf widget when typing `ralph` to still list plan directories, so that the existing workflow is preserved.
3. As a developer, I want CTRL-O to show only top-level plan directories (not nested subdirectories like `issues/`), so that the list stays focused.
4. As a developer, I want the fzf widget to display the plan basename as the label and insert the absolute path, so that the selection is immediately usable as a `ralph` argument.
5. As a developer, I want tab completion to insert the absolute path and display the plan basename as description, consistent with other completions in the project.
6. As a developer, I want the helper that lists plans to be testable in isolation from FZF and from zsh completion, so that regressions are easy to catch.

## Implementation Decisions

### Module 1 — `plan-list-raw` (new deep helper)

A new autoloaded function in the `plan/` domain.

- Reads the git root via `git-directory-root`, then lists direct subdirectories of `plans/` (depth 1) using `fd --type directory --max-depth 1`.
- Output format: one line per plan, two fields separated by `▮`: `fullAbsolutePath▮basename`.
- Returns silently (exit 0, no output) when the `plans/` directory does not exist.
- No arguments; the plans directory is always derived from the current git root.

### Module 2 — `fzf-fs-directories-plans/` (rename + delegate)

The entire `fzf-fs-directories-ralph/` family is renamed to `fzf-fs-directories-plans/`. The `-source` function is rewritten to consume `plan-list-raw` output and reformat it into the two-column FZF format (`fullPath   basename`) expected by `fzf-fs-directories-shared-postprocess`. All internal references (prompt, options, entry point) are updated to use the `plans` name.

The `fzf-fs-shared-source --max-depth` change introduced earlier (on the `ralph-complete` branch) is preserved but the ralph-specific source no longer calls it directly — `plan-list-raw` owns the depth constraint now.

### Module 3+4 — `complete-plans` + `_plans` compdef + wiring

- `complete-plans`: consumes `plan-list-raw`, reformats each line as `fullAbsolutePath:basename` for `_describe`.
- `_plans`: standard compdef wrapper using `_describe -V` with `completion-header`, identical pattern to `_skills`.
- `compdef.zsh`: adds `compdef _plans ralph` in the AI section.
- `ctrl-o.zsh`: renames the `oroshi-fzf-directories-ralph-selection` function and its comment to use `plans`.

## Testing Decisions

Good tests cover observable output and exit codes only — not internal helpers or implementation details.

- **Module 1 (`plan-list-raw`)**: full bats test suite. Tests verify:
  - Direct subdirectories appear in output.
  - Nested subdirectories (e.g. `issues/` inside a plan) do not appear.
  - Each output line matches the `fullAbsolutePath▮basename` format exactly.
  - Empty output (exit 0) when `plans/` does not exist.
  - Prior art: `fzf-claude-sessions-source-no-query.bats`, `fzf-fs-shared-preview-header.bats`.
- **Module 2 (`fzf-fs-directories-plans-source`)**: scaffold tests only (`.scaffold.bats`), providing a red → green checkpoint during development. These files are deleted after the issue is merged.
- **Modules 3+4**: no tests. `complete-plans` and `_plans` are thin formatters over `plan-list-raw`; their correctness follows from Module 1's tests.

## Out of Scope

- Colorizing the FZF display (e.g. ANSI color via `fd --color always`) — `plan-list-raw` returns plain paths; color can be added later at the FZF layer.
- Supporting multiple `plans/` roots or monorepo scenarios.
- Completion for `ralph --max` flag values.
- Renaming the `plans/` directory itself or changing how `ralph` resolves its argument.

## Further Notes

The `fzf-fs-shared-source --max-depth` feature introduced on this branch remains in place but is now only used by other consumers. The ralph/plans source no longer calls it directly since depth control is encapsulated in `plan-list-raw`.
