## Problem Statement

When using fzf-powered pickers (e.g. `vfa` + ctrl-p for staging git files), colors are not
rendered correctly. The fzf option files reference `$COLOR_ALIAS_*` and `$COLOR_*` environment
variables that no longer exist — they were part of a legacy theming system that has been
replaced by the `$COLORS` associative array. Because these variables are undefined, fzf
receives empty strings for color values and falls back to defaults, breaking the intended
visual theming across all affected pickers.

One file (`fzf-packages-apt-source-generate`) also hard-codes raw ANSI escape sequences
(`\e[38;5;${COLOR_ALIAS_*}m`) rather than using the `colorize` helper, making it
inconsistent with every other file in the subsystem.

## Solution

Migrate all 12 fzf option/preview/source files from the old `$COLOR_ALIAS_*` / `$COLOR_*`
variables to the current `$COLORS[key]` associative array. Add a `colors-load-definitions`
call to every file that uses `$COLORS[...]` and does not already have one. Refactor the
one file that uses raw ANSI escape codes to use `colorize` instead, matching the rest of
the subsystem.

## User Stories

1. As a developer using `vfa` + ctrl-p, I want the git-stageable file picker to display
   correctly themed colors, so that modified files are visually distinguishable.
2. As a developer using the commands picker, I want function names highlighted in the
   correct semantic color, so that the picker is easy to scan.
3. As a developer using the regexp picker, I want the disabled/prompt state colored with
   the regexp semantic color, so that the search mode is immediately clear.
4. As a developer using the apt package picker, I want installed packages to appear in the
   correct installed-package color, so that I can distinguish installed from available.
5. As a developer using the apt package preview, I want the package name, install status,
   and description each colored with their semantic color, so that the preview is easy to read.
6. As a developer using the Claude sessions picker, I want the prompt styled with the AI
   semantic color, so that the session picker is visually consistent with other Claude UI.
7. As a developer using the Claude sessions preview, I want dates and comments colored
   correctly, so that session metadata is easy to parse at a glance.
8. As a developer using the bats test picker, I want the prompt colored with the
   language-bats semantic color, so that the picker matches the bats theming convention.
9. As a developer using the Docker remote images picker, I want the prompt colored with
   the docker-image-remote semantic color, so that the picker is visually consistent.
10. As a developer using any file/directory preview, I want executable files colored with
    the executable semantic color, so that scripts are visually identified in the header.
11. As a theme maintainer, I want all fzf files to source `colors-load-definitions` before
    accessing `$COLORS[...]`, so that there are no load-order surprises.
12. As a theme maintainer, I want all color output in fzf files to go through `colorize`,
    so that the subsystem is consistent and raw ANSI codes do not leak into source files.

## Implementation Decisions

### Variable mapping

The old naming convention maps directly to `$COLORS` keys via lowercase + underscore-to-hyphen:

| Old variable | New key |
|---|---|
| `$COLOR_ALIAS_FUNCTION` | `$COLORS[function]` |
| `$COLOR_ALIAS_TEXT` | `$COLORS[text]` |
| `$COLOR_ALIAS_TERMINAL` | `$COLORS[terminal]` |
| `$COLOR_ALIAS_HEADER` | `$COLORS[header]` |
| `$COLOR_ALIAS_REGEXP` | `$COLORS[regexp]` |
| `$COLOR_ALIAS_DIRECTORY` | `$COLORS[directory]` |
| `$COLOR_ALIAS_GIT_MODIFIED` | `$COLORS[git-modified]` |
| `$COLOR_ALIAS_PACKAGE` | `$COLORS[package]` |
| `$COLOR_ALIAS_PACKAGE_INSTALLED` | `$COLORS[package-installed]` |
| `$COLOR_ALIAS_SUCCESS` | `$COLORS[success]` |
| `$COLOR_ALIAS_COMMENT` | `$COLORS[comment]` |
| `$COLOR_ALIAS_AI` | `$COLORS[ai]` |
| `$COLOR_ALIAS_DATE` | `$COLORS[date]` |
| `$COLOR_ALIAS_LANGUAGE_BATS` | `$COLORS[language-bats]` |
| `$COLOR_ALIAS_DOCKER_IMAGE_REMOTE` | `$COLORS[docker-image-remote]` |
| `$COLOR_ALIAS_EXECUTABLE` | `$COLORS[executable]` |
| `$COLOR_BLACK` | `$COLORS[black]` |
| `$COLOR_WHITE` | `$COLORS[white]` |
| `$COLOR_GREEN` | `$COLORS[green]` |
| `$COLOR_GRAY_2` | `$COLORS[gray-2]` |

### colors-load-definitions guard

Every file that references `$COLORS[...]` must call `colors-load-definitions` near the top,
after `setopt local_options err_return`. Files that only call `icons-load-definitions` today
must have `colors-load-definitions` added alongside it. `fzf-fs-shared-preview-header`
already has it and does not need it added.

### colorize refactor in fzf-packages-apt-source-generate

This is the only file in the subsystem that emits raw ANSI escape sequences. The inline
`\e[38;5;Nm...\e[00m` pattern must be replaced with `colorize` calls, matching every other
file. Since `$COLORS[package-installed]` holds the same 256-color number that was previously
in `$COLOR_ALIAS_PACKAGE_INSTALLED`, the visual output is identical after the refactor.

### Scope per file group

- **git** (`fzf-git-files-stageable-options`): swap 3 variables, add `colors-load-definitions`
- **commands** (`fzf-commands-options`): swap 5 variables, add `colors-load-definitions`
- **regexp** (`fzf-regexp-shared-options`): swap 2 variables, add `colors-load-definitions`
- **packages-apt** (3 files): swap variables + colorize refactor in source-generate
- **claude-sessions** (3 files): swap variables, add `colors-load-definitions` where missing
- **bats** (`fzf-bats-test-options`): swap 3 variables, add `colors-load-definitions`
- **docker** (`fzf-docker-images-remote-options`): swap 3 variables, add `colors-load-definitions`
- **fs** (`fzf-fs-shared-preview-header`): swap `COLOR_ALIAS_EXECUTABLE` only — `colors-load-definitions` already present

## Testing Decisions

No tests are written for this migration. The change is a mechanical variable substitution
with no behavioral difference — the `$COLORS[key]` values are the same 256-color numbers
that `$COLOR_ALIAS_*` were intended to hold. Regression is verified manually by opening
each affected picker and confirming colors render.

## Out of Scope

- The `FILETYPE_${ext:u}_COLOR` dynamic variable pattern in `fzf-fs-shared-preview-header` —
  this is a separate theming subsystem, not `COLOR_ALIAS_*`.
- Any fzf files that already use `$COLORS[...]` correctly (e.g. `fzf-fs-shared-options`,
  `fzf-fs-files-shared-options`, `fzf-fs-directories-shared-options`, `fzf.zsh`).
- Theme value changes — this migration preserves existing color choices, only updating
  how they are referenced.
- Adding new semantic color keys to `colors.zsh`.
- Writing bats tests for fzf option/preview/source files.
