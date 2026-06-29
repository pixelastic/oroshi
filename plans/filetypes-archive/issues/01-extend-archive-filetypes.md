## TLDR

Add 7 missing archive extensions to the filetype source data and rebuild the dist file.

## What to build

Add `Z`, `bz2`, `htmlz`, `tar`, `tar.bz2`, `tar.lzma`, `tbz2` to the `archive` group's `patterns` array in `src/filetypes.jsonc`, following the existing plain-string convention.

Run `filetypes-build` to regenerate `dist/filetypes.zsh`. The new entries must appear in the dist with `group=archive`, resolved color/icon values, and `bold=1` (inherited from the archive group default).

## Acceptance criteria

- [ ] All 7 extensions present in `src/filetypes.jsonc` under the `archive` group
- [ ] `filetypes-build` runs without error
- [ ] `dist/filetypes.zsh` contains `<key>:group=archive` entries for each new extension
- [ ] Existing archive entries are unchanged
