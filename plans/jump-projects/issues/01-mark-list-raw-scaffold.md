## TLDR

Create the `mark-list-raw` primitive and the `mark.zsh` alias file with new MARKPATH location.

## What to build

Create `tools/term/zsh/config/functions/autoload/misc/mark/mark-list-raw` — an autoloaded function that lists all symlinks in `$OROSHI_MARKPATH` using `▮` separator (`name▮path`).

Create `tools/term/zsh/config/aliases/mark.zsh` with:
- `export MARKPATH=$OROSHI_TMP_FOLDER/marks`
- `alias j='mark-jump'`
- `alias m='mark-create'`
- `alias mR='mark-delete'`
- `alias ml='mark-list'`

The `mark-list-raw` function iterates over `$OROSHI_MARKPATH/*`, resolves each symlink target, and outputs one line per mark in `name▮resolvedPath` format.

Prior art: `helper-list-raw` uses the same `▮` separator convention.

## Behavioral Tests

**mark-list-raw with marks present:**
- outputs one line per symlink in MARKPATH
- each line uses ▮ separator with name and resolved path
- name is the symlink filename

**mark-list-raw with empty MARKPATH:**
- outputs nothing, exits 0

**mark-list-raw with nonexistent MARKPATH:**
- outputs nothing, exits 0

## Acceptance criteria

- [ ] `misc/mark/mark-list-raw` exists and is autoloadable
- [ ] Output format is `name▮resolvedPath` per line
- [ ] `mark.zsh` exports MARKPATH to `$OROSHI_TMP_FOLDER/marks`
- [ ] `mark.zsh` defines all four aliases
- [ ] All behavioral tests pass
