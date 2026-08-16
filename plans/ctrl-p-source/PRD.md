## Problem Statement

Ctrl-P in Neovim opens the FZF picker but the file list is empty. The FZF window appears, options load correctly, but no files are displayed.

The root cause is that fzf.vim's `fzf#run()` switches `&shell` to `sh` before launching the terminal (via `termopen()`). Since FZF source commands like `ctrl-p` are ZSH autoloaded functions (not scripts in `$PATH`), `sh` cannot find them and the source produces no output.

The `--options` call works because it runs via `systemlist()` before `fzf#run()` changes the shell. The `--preview` works because it already uses the `bin-zsh` wrapper.

## Solution

Prefix all FZF source commands in disk.lua with `bin-zsh`, a shebang-based ZSH wrapper that exists in `$PATH` and can call autoloaded ZSH functions from any shell context.

Keep the source as a string (not a list via `systemlist()`) to preserve streaming behavior — FZF opens immediately and displays results progressively as they arrive through the pipe.

## User Stories

1. As a Neovim user, I want Ctrl-P to display the project file list, so that I can navigate to any file quickly.
2. As a Neovim user, I want Ctrl-Shift-P to display the directory file list, so that I can navigate to files in the current directory.
3. As a Neovim user, I want the file list to stream progressively into FZF, so that I can start typing before the full list loads.
4. As a Neovim user, I want Ctrl-G regex search to use the same source pattern as Ctrl-P, so that the codebase is consistent and serves as a correct example for future pickers.
5. As a Neovim user, I want Ctrl-Shift-G regex search to use the same source pattern, so that all four pickers follow one convention.

## Implementation Decisions

- Only `disk.lua` is modified — the ZSH functions and `bin-zsh` wrapper remain unchanged.
- All four pickers (ctrl-p, ctrl-shift-p, ctrl-g, ctrl-shift-g) are normalized to the same pattern: `source = "bin-zsh <cmd> --source"` as a string, not a list.
- For ctrl-g and ctrl-shift-g, the change is a no-op functionally (initial source is always empty — reload bindings already use `bin-zsh` via `SCRIPT_NAME`). The purpose is pattern consistency.
- The `sinklist` postprocess commands (`"ctrl-p --postprocess"` etc.) are NOT prefixed with `bin-zsh` — they run via `vim.fn.system()` after `fzf#run()` restores `&shell` to `zsh`.

## Testing Decisions

- Manual verification: open Neovim, press Ctrl-P, confirm files appear and are navigable.
- Manual verification: press Ctrl-Shift-P, confirm directory files appear.
- Manual verification: press Ctrl-G, type a query, confirm results stream in.
- Manual verification: press Ctrl-Shift-G, type a query, confirm results stream in.
- No automated tests — this is a Neovim plugin config change with no testable interface.

## Out of Scope

- Modifying fzf.vim itself to not switch `&shell` to `sh`.
- Adding `bin-zsh` prefix to postprocess commands (not needed — they run after shell restoration).
- Extracting a Lua helper for the `fzf#run` pattern (premature abstraction for 4 call sites).
- Creating the missing FZF glossary referenced in GLOSSARY.md.

## Further Notes

The `bin-zsh` wrapper is a one-line script (`"$@"`) with a `#!/usr/bin/env zsh` shebang. It already exists and is already used by FZF preview commands. This fix extends its use to source commands.
