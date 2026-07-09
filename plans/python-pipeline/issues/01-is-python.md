## TLDR

New autoload function that returns true iff a file has a `.py` extension.

## What to build

Create `tools/term/zsh/config/functions/autoload/term/python/is-python`.

The function takes a single file path and exits 0 if the file has a `.py` extension, 1 otherwise. Symlinks, directories, and missing files all return false. No shebang detection — extension only.

Follow the `is-js` pattern, but simpler: no shebang fallback.

## Behavioral Tests

**`.py` extension**
- Returns true for a regular `.py` file

**Other cases → false**
- Returns false for a file with a different extension (e.g. `.js`)
- Returns false for a file with no extension
- Returns false for a symlink pointing to a `.py` file
- Returns false for a directory named `foo.py`
- Returns false for a path that does not exist

## Acceptance criteria

- [ ] `is-python foo.py` exits 0
- [ ] `is-python foo.js` exits 1
- [ ] `is-python foo` exits 1
- [ ] Symlinks return false
- [ ] Directories return false
- [ ] Missing files return false
- [ ] BATS tests pass (`bats tools/term/zsh/config/functions/autoload/term/python/__tests__/is-python.bats`)
- [ ] `zsh-lint` passes on the new function
