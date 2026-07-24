## Problem Statement

When the user types `yrt` (or `yrtw`, `yrtff`) and presses CTRL-P, the default file picker opens showing all project files. The user expects a scoped picker showing only JS test files, similar to how `bats` shows only `.bats` files and `vfa` shows only stageable files.

## Solution

Create a new fzf picker script (`fzf-js-test`) that lists only `.js` files inside `__tests__/` directories, with the same visual style as the default `ctrl-p` picker (context-badge prompt, directory-colored paths, filetype-colored filenames). Wire it into the `specialPickers` dispatch in `ctrl-p.zsh` for `yrt`, `yrtw`, and `yrtff`.

## User Stories

1. As a developer, I want CTRL-P after `yrt` to show only JS test files, so that I can quickly pick a test to run without scrolling through unrelated files.
2. As a developer, I want CTRL-P after `yrtw` to show only JS test files, so that I can pick a test to watch.
3. As a developer, I want CTRL-P after `yrtff` to show only JS test files, so that I can pick a test to run in fail-fast mode.
4. As a developer, I want the picker to look identical to the default `ctrl-p` (same prompt, same colorization), so that the experience feels consistent.
5. As a developer, I want the selected path to be absolute, so that `yarn-run-test` receives a path it can resolve regardless of my current working directory.
6. As a developer, I want the picker to show nothing (empty fzf) when no test files exist, rather than falling back to all files.

## Implementation Decisions

- **New picker script `fzf-js-test`**: follows the standard fzf dispatch pattern (`fzf-source`, `fzf-options`, `fzf-dispatch`).
- **File discovery**: `fd --type file --extension js --full-path '/__tests__/' --base-directory "$gitRoot"` — single command, no pipes. Only `.js` files, not `.ts`.
- **Display format**: `absolute_path▮colorized_relative_path` using `fzf-colorize-path` (directories in green, filename by filetype color). Same two-column delimiter pattern as `ctrl-p`.
- **Prompt and fzf options**: reuse `fzf-options-files` — context-badge, path scheme, query/info colors. Identical visual to `ctrl-p`.
- **Preview**: reuse `fzf-fs-preview.zsh` — file content preview, same as `ctrl-p`.
- **Postprocess**: default from `init.zsh` (strips after `▮`, returns absolute path). No custom override needed.
- **Keybinding mapping**: add three entries to `specialPickers` associative array: `yrt`, `yrtw`, `yrtff` all pointing to `fzf-js-test`.
- **No separate list-raw helper**: unlike `fzf-bats-test` which calls `bats-test-list-raw` (shared with completion), the `fd` call is inlined in `fzf-source` since no other consumer needs this list.

## Testing Decisions

- Only the picker script (`fzf-js-test`) gets tests. The keybinding mapping is pure config — no tests per project convention.
- Tests verify external behavior through the dispatch flags (`--source`, `--options`), not internal implementation.
- Mock `fd` with `bats_mock` to return controlled file lists.
- Three tests mirroring `fzf-bats-test.bats`:
  1. `--source` first field is the absolute filepath
  2. `--source` second field is ANSI-colored
  3. `--source` outputs nothing when no test files exist
- Prior art: `scripts/bin/fzf/__tests__/fzf-bats-test.bats`

## Out of Scope

- Picker for `yrl` (yarn run lint) — separate concern.
- Including `.ts` / `.tsx` / `.jsx` extensions — only `.js` for now.
- Custom icon or color in the fzf prompt — reuses default `ctrl-p` prompt.
- Autocompletion for `yrt` arguments — not related to CTRL-P picker.
