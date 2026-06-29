## TLDR

Replace the hardcoded Archives glob in `compdef.zsh` with a dynamic call to `compdef-glob-from-group`.

## What to build

Source `compdef-glob-from-group` at the top of `compdef.zsh` (using `${0:A:h}` relative path, same convention as other sourced files in `completion/`). Update the Archives block to call `$(compdef-glob-from-group archive)` instead of the hardcoded extension list. `unfunction compdef-glob-from-group` at the bottom of the file.

## Scaffolding Tests

The hardcoded archive extension list no longer exists in `compdef.zsh` — the Archives block uses `compdef-glob-from-group` instead.

## Acceptance criteria

- [ ] `compdef-glob-from-group` is sourced at the top of `compdef.zsh`
- [ ] Archives block uses `$(compdef-glob-from-group archive)` — no hardcoded extension list
- [ ] `unfunction compdef-glob-from-group` present at bottom of `compdef.zsh`
- [ ] `zsh-lint` passes on `compdef.zsh`
