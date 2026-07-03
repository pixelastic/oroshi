## Problem Statement

`ctrl-p` and `ctrl-shift-p` are two file-search scripts that share the same purpose and the same fzf lib dependencies, but have drifted apart. Their fzf options are nearly identical yet duplicated — meaning any future change to shared options must be applied in two places. In addition, `ctrl-shift-p` is missing three color options present in `ctrl-p`, uses an inconsistent `SEARCH_PATH` pattern, and has a redundant `--nth=1,2` flag.

## Solution

Extract the shared fzf options into a new deep-module helper `fzf-options-files`, sourced by both scripts. The helper owns its own dependencies (base options, prompt formatting). Each script's `fzf-options()` becomes a one-liner delegation. `ctrl-shift-p` is updated to use a top-level `SEARCH_PATH` variable and aligned structurally with `ctrl-p`. The only remaining difference between the two scripts is the value of `SEARCH_PATH`.

## User Stories

1. As a developer, I want `ctrl-p` and `ctrl-shift-p` to share their fzf option logic, so that future option changes only need to be made in one place.
2. As a developer, I want the color options (`query`, `info`, `separator`) to be present in both file-search scripts, so that the UI is consistent between them.
3. As a developer, I want `ctrl-shift-p` to use a `SEARCH_PATH` variable instead of inlining `$PWD`, so that the search path is defined once and reused consistently across `fzf-source` and `fzf-options`.
4. As a developer, I want `ctrl-shift-p` to have the same source order as `ctrl-p`, so that the two scripts are structurally identical.
5. As a developer, I want the redundant `--nth=1,2` flag removed from `ctrl-shift-p`, so that there is no silent divergence from `ctrl-p`'s behavior.
6. As a developer, I want the new helper to self-source its own dependencies, so that each script's source block stays lean and callers don't need to know about transitive deps.

## Implementation Decisions

- A new lib helper `fzf-options-files` is created in the `__lib` directory alongside existing helpers.
- The helper accepts two arguments: `scriptName` and `searchPath`.
- The helper calls `fzf-options-base` internally (emitting base options: `--ansi`, `--layout`, `--delimiter`, default prompt color).
- The helper calls `colors-load-definitions` internally before referencing `$COLORS[file]`.
- The helper emits: `--with-nth=2`, `--scheme=path`, `--tiebreak=pathname,chunk`, `--preview`, `--prompt`, `--color=query`, `--color=info`, `--color=separator`.
- The helper self-sources `fzf-options-base.zsh` and `fzf-options-prompt-directory.zsh` at its top, consistent with the pattern used by `fzf-source-files.zsh` (which self-sources `fzf-colorize-path.zsh`).
- Both `ctrl-p` and `ctrl-shift-p` replace their explicit `source` lines for `fzf-options-base` and `fzf-options-prompt-directory` with a single `source fzf-options-files.zsh`.
- Both scripts' `fzf-options()` functions become a single delegation call: `fzf-options-files "$SCRIPT_NAME" "$SEARCH_PATH"`.
- `ctrl-shift-p` gains a top-level `SEARCH_PATH="$PWD"` assignment, mirroring `ctrl-p`'s pattern.
- `ctrl-shift-p`'s source order is aligned to match `ctrl-p`: `init` → `fzf-options-files` → `fzf-source-files` → `fzf-fs-preview`.
- `--nth=1,2` is dropped from `ctrl-shift-p`: with `--delimiter=▮` and exactly two fields, this flag is redundant with fzf's default behavior.

## Testing Decisions

No new tests are written for this change. The new helper only echoes fzf flag strings and delegates to already-tested collaborators (`fzf-options-base`, `fzf-options-prompt-directory`). A unit test would just assert that specific strings are echoed — testing implementation, not behavior.

The observable behavior of both scripts (file listing, path extraction) is already covered by existing bats tests for `--source` and `--postprocess`. These tests continue to serve as the regression baseline.

Prior art: `scripts/bin/fzf/__tests__/ctrl-p.bats` and `ctrl-shift-p.bats`.

## Out of Scope

- Adding `--options` test coverage to `ctrl-p.bats` or `ctrl-shift-p.bats`.
- Changes to `fzf-source-files`, `fzf-options-prompt-directory`, or any other lib.
- Unifying the `SEARCH_PATH` logic between the two scripts (they intentionally differ: `ctrl-p` uses git root, `ctrl-shift-p` uses `$PWD`).
- Any changes to other fzf scripts (ctrl-b, ctrl-r, ctrl-g, etc.).
