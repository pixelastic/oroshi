## Problem Statement

When using the `vfa` fzf picker (dirty stageable files), paths containing spaces (e.g. `Super Mario Bros 3/rom.nes`) appear with double quotes in the file list. This breaks display, preview, and output because `git status --porcelain` wraps space-containing paths in C-style quotes, and the parsing functions pass them through verbatim.

Additionally, the three `-raw` git file list functions (`dirty-raw`, `dirty-stageable-raw`, `staged-raw`) each independently call `git status --porcelain` and parse its output, duplicating the same parsing logic. They also use `:` as their output separator, inconsistent with the project's `▮` convention for raw output.

## Solution

Create a new `git-status-raw` helper that centralizes `git status --porcelain` parsing with `core.quotePath=false` to eliminate quoting. It outputs `filepath▮STATUS` format. The three existing `-raw` functions become thin filters over `git-status-raw`, and all consumers migrate from `:` to `▮` splitting.

## User Stories

1. As a user with spaces in directory names, I want `vfa` to display paths without surrounding quotes, so that the file list is readable
2. As a user with spaces in directory names, I want the fzf preview pane to work when selecting a space-containing path, so that I can see the diff before staging
3. As a user with spaces in directory names, I want the selected path inserted correctly into my command buffer, so that downstream commands (vim, git add) work
4. As a developer, I want a single `git-status-raw` helper that normalizes porcelain output, so that all git file list functions share one parser
5. As a developer, I want all `-raw` functions to use the `▮` separator, so that the output format is consistent with the project convention
6. As a developer, I want renamed files to include the old path as a third column, so that consumers who need rename info can access it
7. As a user running `vf` (dirty file list), I want paths with spaces to display correctly, so that the same bug doesn't affect the non-stageable picker
8. As a user running `git-file-lint` or `git-file-test`, I want paths with spaces to resolve correctly, so that linting and testing work on space-containing paths

## Implementation Decisions

- New `git-status-raw` function placed in `autoload/git/` (not `git/file/` — it's a git status wrapper, not file-specific)
- Uses `git -c core.quotePath=false status --porcelain --short` to avoid C-style quoting at source
- Output format: `filepath▮STATUS` where STATUS is a single letter (M, A, D, R)
- Renames output three columns: `new-path▮R▮old-path`
- The three `-raw` functions become filters on `git-status-raw` and output `filepath▮STATUS`
- `git-file-list-dirty-raw` keeps its path argument support, passing it through to `git-status-raw`
- All 10 consumers migrate from `${(@s/:/)rawLine}` split to `▮` split with reversed column order
- `git-directory-dirty-count` unchanged (only counts lines, no parsing)

## Testing Decisions

- Good tests: exercise the function's external output format against a real git repo (temp dir with commits, modifications, renames)
- `git-status-raw` gets a new test file covering: clean repo, modified file, added file, deleted file, renamed file, path with spaces, multiple files
- Existing `git-file-list-dirty-raw.bats` updated: assertions change from `STATUS:filepath` to `filepath▮STATUS`, add a test for paths with spaces
- New tests for `git-file-list-dirty-stageable-raw` and `git-file-list-staged-raw`
- Prior art: `git/file/__tests__/git-file-list-dirty-raw.bats` — same pattern of temp git repo with setup/commit/modify cycle
- fzf picker test `fzf-git-files-dirty-stageable.bats` updated to verify paths with spaces

## Out of Scope

- Refactoring `ctrl-p` core file picker (already handles spaces correctly via `fd` + `▮`)
- Changing the non-raw display functions' output format (they output colorized text, not structured data)
- Handling exotic characters beyond spaces (single quotes, `$`, etc.) — `core.quotePath=false` handles all of these
- Adding `▮` separator to functions outside the git file list family

## Further Notes

- `core.quotePath=false` is passed per-command (`git -c`), not set globally — no impact on user's git config
- The `▮` character is the project-wide convention for structured output separation in raw functions
