## TLDR

Apply the ZSH script color and icon to autoloaded functions in the fzf preview header.

## What to build

In `fzf-preview-header`, after the extension-based color and icon lookup yields empty results, add a call to `is-zsh-autoload-function` on the full path. If `REPLY="1"`, set `color` to `FILETYPES[zsh:color]` and `icon` to `FILETYPES[zsh:icon]`. The existing executable fallback remains in place after this check.

This makes the preview header consistent with `fzf-colorize-path`: an autoloaded function shows the script icon and violet color instead of a blank icon and no color.

## Acceptance criteria

- [ ] `fzf-preview-header`: autoload check inserted after extension lookup, before executable fallback
- [ ] Color set to `FILETYPES[zsh:color]` for autoload files
- [ ] Icon set to `FILETYPES[zsh:icon]` for autoload files
- [ ] Existing behavior unchanged for all other file types
- [ ] `zsh-lint` passes on the modified file
