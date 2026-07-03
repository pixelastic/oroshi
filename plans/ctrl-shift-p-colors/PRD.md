## Problem Statement

`ctrl-shift-p` displays file results without colors, while `ctrl-p` (which covers the same use case scoped to the git root) displays them with directory and filetype colorization. The inconsistency degrades the fzf experience: the user cannot visually distinguish directories from filenames, or identify file types at a glance, when using `ctrl-shift-p`.

The root cause is that `ctrl-p` inlines its own colorized source loop, while `ctrl-shift-p` delegates to the shared `fzf-source-files` library which emits raw, uncolored paths.

## Solution

Centralize colorized file listing in `fzf-source-files` so that every caller — both `ctrl-shift-p` and `ctrl-p` — gets colorization for free. The `fzf-source-files` function becomes the single authoritative source for two-column file output with ANSI-colorized display paths. `ctrl-p` is refactored to delegate to it, removing its inlined source loop.

## User Stories

1. As a developer using `ctrl-shift-p`, I want directory segments colorized in the fzf display column, so that I can visually scan file paths at a glance.
2. As a developer using `ctrl-shift-p`, I want filenames colorized by extension, so that I can identify file types without reading extensions carefully.
3. As a developer using `ctrl-shift-p`, I want executable files without an extension colorized in the executable color, so that scripts and binaries stand out.
4. As a developer using `ctrl-p`, I want colorization to remain unchanged after the refactor, so that existing muscle memory is preserved.
5. As a developer, I want colorization logic to live in one place, so that future color changes only need to be made once.
6. As a developer, I want the absolute path in column 1 to remain uncolorized, so that postprocess extraction of the path works correctly without stripping ANSI codes.

## Implementation Decisions

- `fzf-source-files` is the deep module: it encapsulates file listing + colorization. Its interface is unchanged — `fzf-source-files <searchPath>` emits `absPath▮colorizedDisplay` lines — but the display column gains ANSI color sequences.
- `fzf-source-files` sources the `fzf-colorize-path` helper at the top of the file, making it self-contained. This follows the precedent set by `fzf-regexp-common`, which also sources `fzf-colorize-path` at its own top level.
- Inside the loop, `fzf-colorize-path` is called with two arguments: the relative display path and the absolute real path (used for executable detection). The colorized result is read from `$REPLY` (no subshell).
- `ctrl-p` is refactored to delegate its `fzf-source` function to `fzf-source-files`, removing the inlined file listing loop.
- `ctrl-p` no longer sources `fzf-colorize-path` directly; it sources `fzf-source-files` instead, which pulls in the dependency transitively.
- `colors-load-definitions` and `filetypes-load-definitions` are idempotent (no-op after first load). They are called inside each function that needs them, not at script level. The script-level pre-load calls in `ctrl-p` are removed. `colors-load-definitions` is added inside `ctrl-p`'s `fzf-options` function, which references `$COLORS[file]`.
- `ctrl-shift-o` (directory picker, uses `fzf-source-directories`) is not affected — it already colorizes via `colorize` directly.

## Testing Decisions

Good tests verify observable output behavior, not internal implementation details. A test should pass regardless of which internal function produces the color — it only checks that column 2 of the output contains ANSI escape sequences, and that column 1 does not.

**Module tested:** `fzf-source-files` (lib unit tests)

- A new bats test file is created for `fzf-source-files` in the lib's `__tests__` directory, following the structure of the existing `fzf-colorize-path.bats` (mock `filetypes-load-definitions` and `colors-load-definitions` in `setup`, use `bats_run_zsh` with an inline source prefix).
- Tests cover: column 2 contains ANSI sequences for a plain file, column 1 has no ANSI sequences, executable files get executable color in column 2.
- The existing `ctrl-p.bats` and `ctrl-shift-p.bats` integration tests are not modified — they cover file discovery and postprocess behavior, which is unchanged.

## Out of Scope

- Colorization changes to `fzf-source-directories` (`ctrl-shift-o`) — already handled correctly.
- Changes to any NeoVim integration — the fzf scripts are shell-level; neovim calls them as subprocesses.
- Adding colorization tests at the `ctrl-p` or `ctrl-shift-p` integration level — covered by lib unit tests.
- Changes to `fzf-regexp-common` or any other lib that already sources `fzf-colorize-path` independently.
