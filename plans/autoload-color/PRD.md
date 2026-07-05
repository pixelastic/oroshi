## Problem Statement

Autoloaded ZSH functions are extensionless files living under `functions/autoload/` directories. Because all file coloring in this system is extension-based — `LS_COLORS` uses `*.ext=color` glob patterns, and fzf colorization extracts the extension from the filename — these files appear in white (default terminal color) in both `ls`/`exa` output and the fzf file picker (ctrl-p). They are visually indistinguishable from unknown or unrecognized files, even though they are ZSH scripts and should be treated as such.

## Solution

Introduce a shared helper `is-zsh-autoload-function` that detects whether a file path belongs to an autoloaded ZSH function (path contains `*/functions/autoload/*` and the file has no extension). Integrate this helper into every location that performs file coloring, so that autoloaded functions are rendered with the same color and icon as `.zsh` scripts (violet-3).

For `ls`/`exa` output specifically — where `LS_COLORS` cannot do path-based matching — convert `better-ls` to ZSH and override the `fi=` (regular file fallback) color when the current working directory is inside an autoload directory.

## User Stories

1. As a developer navigating the oroshi repo with fzf (ctrl-p), I want autoloaded ZSH functions to appear in the ZSH script color, so that I can visually distinguish them from generic unknown files.
2. As a developer running `ls` inside a `functions/autoload/` directory, I want the extensionless function files to appear in the ZSH script color instead of white, so that the directory listing is visually consistent with the rest of the codebase.
3. As a developer viewing a file preview in fzf, I want autoloaded ZSH functions to show the script icon and violet color in the preview header, so that the file type is immediately recognizable.
4. As a developer writing a new zsh-lint rule, I want a single canonical helper to detect autoloaded functions, so that I do not need to re-implement the path pattern inline.
5. As a developer maintaining `is-zsh`, I want the autoload detection logic to live in a dedicated helper, so that `is-zsh` stays focused on the broader question of "is this file ZSH?" and delegates the autoload-specific check.

## Implementation Decisions

- **Shared detection helper**: A new autoload function `is-zsh-autoload-function` encapsulates the detection logic. It takes a file path, checks that (a) the path matches `*/functions/autoload/*` and (b) the file has no extension (`${path:e} == ""`). It writes `REPLY="1"` if both conditions hold, `REPLY="0"` otherwise. No stdout, no subshell — callers read `$REPLY` directly.

- **Helper location**: Placed as a sibling of `is-zsh` in the `term/zsh` autoload subdirectory, since both functions concern ZSH file classification.

- **Refactors grouped**: `is-zsh`, the `missingErrReturn` lint rule, and `fzf-colorize-path` all inline the same `*/functions/autoload/*` path check today. All three are refactored to call `is-zsh-autoload-function` instead. No behavior change — these are pure refactors.

- **`better-ls` conversion**: `better-ls` is converted from bash to ZSH, enabling it to call `filetypes-load-definitions` and read `FILETYPES[zsh:color]`. When `$PWD` matches `*/functions/autoload*`, it appends `:fi=38;5;$FILETYPES[zsh:color]` to `LS_COLORS` for the `exa` call only. The `fi=` key is the regular-file fallback in `LS_COLORS`; extension-matched files are unaffected. `$PWD` is always used (not the argument passed to `better-ls`) — this edge case is accepted.

- **`fzf-colorize-path`**: After extension lookup fails and before the `-x` executable fallback, call `is-zsh-autoload-function` on `realPath`. If `REPLY=="1"`, apply `FILETYPES[zsh:color]`.

- **`fzf-preview-header`**: Same pattern as `fzf-colorize-path`, with the addition of setting the icon to `FILETYPES[zsh:icon]` alongside the color.

- **Color value**: `FILETYPES[zsh:color]` (violet-3, currently 173). Never hardcoded — always read from the loaded `FILETYPES` assoc array.

- **`LS_COLORS` limitation confirmed**: Standard `LS_COLORS` and `exa`/`eza` (via the `lscolors` Rust crate) only support `*.ext` suffix patterns matched against the filename alone — not path-based globs. The `fi=` override in `better-ls` is the only viable approach for `ls`-style coloring.

## Testing Decisions

Good tests verify external behavior against a stable interface, not implementation details. They set up realistic filesystem fixtures and check observable outputs (REPLY value, ANSI escape sequences in output, environment variable values).

**`is-zsh-autoload-function`** — tested in isolation with bats:
- Returns `REPLY="1"` for a file inside `functions/autoload/` with no extension
- Returns `REPLY="0"` for a file inside `functions/autoload/` that has an extension (e.g. `.bats`)
- Returns `REPLY="0"` for a file outside `functions/autoload/` with no extension
- Returns `REPLY="0"` for a directory inside `functions/autoload/`
- Prior art: `is-zsh.bats` in the same `__tests__` directory

**`better-ls`** — tested with bats via `bats_run_zsh`:
- When called from a `*/functions/autoload/*` directory, the `LS_COLORS` passed to `exa` contains `fi=38;5;<zsh-color>` (mock `exa` with `bats_mock` to capture the environment)
- When called from a non-autoload directory, `LS_COLORS` does not contain the `fi=` override

**Refactors** (`is-zsh`, `missingErrReturn` rule, `fzf-colorize-path`): no new tests. Existing bats suites (`is-zsh.bats`, `rule-missing-err-return.bats`, `fzf-colorize-path.bats`) cover the behavior; the refactors are transparent.

**`fzf-preview-header`**: no tests. The preview header has no dedicated test for the color/icon path and the change is a shallow conditional.

## Out of Scope

- Coloring autoloaded functions in `ls`/`exa` when calling `better-ls` with an explicit path argument that points into an autoload directory (only `$PWD` is checked).
- Supporting path-based `LS_COLORS` patterns in `exa`/`eza` — confirmed not supported by the underlying `lscolors` Rust crate.
- Coloring autoloaded functions from other tools (e.g. `bat`, NeoVim file pickers) — only `better-ls` and fzf are in scope.
- Applying a distinct color to autoloaded functions vs. regular `.zsh` scripts — they use the same color by design.
- Generalizing the detection pattern to any `*/autoload/*` directory — only `*/functions/autoload/*` is supported.
