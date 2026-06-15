## TLDR

Update all consumers to use `FILETYPES[]` + `filetypes-load-definitions`, remove eager loading from `theming/index.zsh`, and delete the old pipeline files.

## What to build

**`ls.zsh`:**
- Add `filetypes-load-definitions` call at top of the inner function
- Replace iteration over `${=FILETYPES_INDEX}` with iteration over `${(k)FILETYPES}` filtered to keys ending in `:pattern`
- Replace `${(P)${:-FILETYPE_${extension}_*}}` dynamic lookups with direct `$FILETYPES[$ext:color]`, `$FILETYPES[$ext:bold]`, `$FILETYPES[$ext:pattern]` subscripts (lowercase extension key)

**`filetype-group`:**
- Add `filetypes-load-definitions` call
- Replace `${(P)${:-FILETYPE_${extension}_GROUP}}` with `$FILETYPES[${filepath:e:l}:group]`

**`img-display`:**
- Add `filetypes-load-definitions` call
- Replace `$FILETYPE_GROUP_IMAGE_COLOR` with `$FILETYPES[image:color]`

**`fzf-fs-shared-preview-header`:**
- Add `filetypes-load-definitions` call
- Replace `${(P)${:-FILETYPE_${fileExtension:u}_COLOR}}` with `$FILETYPES[${fileExtension:l}:color]`
- Replace `${(P)${:-FILETYPE_${fileExtension:u}_ICON}}` with `$FILETYPES[${fileExtension:l}:icon]`

**`theming/index.zsh`:**
- Remove the `source .../env/filetypes.zsh` line — no replacement needed, lazy loading via `filetypes-load-definitions` is sufficient

**Deleted files:**
- `src/filetypes-list.zsh`
- `src/env-generate-filetypes`
- `env/filetypes.zsh`

**Existing tests:** No new tests written. If any existing tests for the updated consumers break
due to test-helper changes, fix them on a case-by-case basis.

## Scaffolding Tests

- `env/filetypes.zsh` no longer exists
- `src/filetypes-list.zsh` no longer exists
- `theming/index.zsh` does not contain a `source` call referencing `env/filetypes.zsh`

## Acceptance criteria

- [ ] `ls.zsh` uses `filetypes-load-definitions` and `$FILETYPES[]` subscripts
- [ ] `filetype-group` uses `filetypes-load-definitions` and `$FILETYPES[$ext:group]`
- [ ] `img-display` uses `filetypes-load-definitions` and `$FILETYPES[image:color]`
- [ ] `fzf-fs-shared-preview-header` uses `filetypes-load-definitions` and `$FILETYPES[]` subscripts
- [ ] `theming/index.zsh` no longer sources `env/filetypes.zsh`
- [ ] Old pipeline files deleted
- [ ] `zsh-lint` passes on all updated files (including the new `missingFiletypesLoad` rule)
- [ ] Shell startup no longer exports `FILETYPE_*` env vars
