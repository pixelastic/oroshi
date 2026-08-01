## TLDR

Audit and relocate non-helper files from autoload/ and scripts/bin/ so scans return only real helpers.

## What to build

Scan `$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/` and `$OROSHI_ROOT/scripts/bin/` for files with extensions (`.md`, `.gif`, `.jpg`, `.png`, `.svg`, `.conf`, `.docx`, etc.) that are not inside `__*` directories.

For each stray file, decide:
- Move to a sibling `__config/` or `__lib/` directory (if it's a resource used by helpers in that domain)
- Delete (if unused)

Known strays from research:
- `autoload/git/worktree/GLOSSARY.md`, `autoload/npm/GLOSSARY.md`, `autoload/project/GLOSSARY.md`
- `autoload/img/gif/default.gif`, `autoload/img/jpg/default.jpg`, `autoload/img/png/default.png`, `autoload/img/svg/default.svg`
- `scripts/bin/kitty/session.conf`
- `scripts/bin/markdown/md2gdocs/reference.docx`

For each relocation, verify nothing references the old path (grep for it).

## Acceptance criteria

- [ ] No files with extensions remain directly in helper directories (outside `__*` dirs)
- [ ] Relocated files are in appropriate `__*` directories
- [ ] No broken references to moved files
