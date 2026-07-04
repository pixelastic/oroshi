## TLDR

New `filetypes-key` autoload function that derives the FILETYPES lookup key from a filename, handling the dotfile case.

## What to build

Create a new autoload function `filetypes-key` in the filetypes autoload directory. It takes a filename (or filepath — use the tail) and writes the corresponding FILETYPES key to `$REPLY` (no subprocess, consistent with the `--reply` pattern used by `colorize` and others in this codebase).

Key derivation rule — mirrors the `filetypes-build` compile step exactly:
- If filename starts with `.` → lowercase the full filename and replace all dots with underscores (e.g. `.fdignore` → `_fdignore`, `.babelrc.json` → `_babelrc_json`)
- Otherwise → return the lowercased extension (e.g. `app.js` → `js`, `Makefile` → `""`)

The function does not access the FILETYPES array — it only computes the key. Callers do their own lookup.

## Behavioral Tests

**Dotfile without secondary extension**
- `.fdignore` → `_fdignore`
- `.gitignore` → `_gitignore`
- `.nvmrc` → `_nvmrc`

**Dotfile with secondary extension**
- `.babelrc.json` → `_babelrc_json`

**Regular file with extension**
- `app.js` → `js`
- `README.md` → `md`

**Regular file without extension**
- `Makefile` → `""` (empty string)

**Filepath input (uses tail)**
- `src/components/app.js` → `js`
- `config/.fdignore` → `_fdignore`

## Acceptance criteria

- [ ] `filetypes-key` autoload function exists in the filetypes autoload directory
- [ ] Returns correct key for dotfiles (dot → underscore, lowercased)
- [ ] Returns correct key for regular files (lowercased extension)
- [ ] Returns empty string for files without extension
- [ ] Accepts full filepaths (uses tail)
- [ ] Writes result to `$REPLY`, no subprocess
- [ ] Bats tests pass for all behavioral test cases above
- [ ] `zsh-lint` passes
- [ ] `bats-lint` passes on the test file
