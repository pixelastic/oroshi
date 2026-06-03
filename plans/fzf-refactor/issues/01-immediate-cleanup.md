## TLDR

Delete dead code that serves no purpose and will never be migrated.

## What to build

Remove all FZF-related code that is confirmed unused before starting the migration.
No replacement is needed for any of these — they are either duplicates or features
that were never actually used.

**Keybinding widgets to remove:**
- Ctrl-T ZSH widget — exact duplicate of Ctrl-Shift-P (same function, two bindings)
- Ctrl-H ZSH widget — git commits picker, user confirmed never used
- Ctrl-J ZSH widget — frequent directories picker, broken and never used

**Aliases to remove:**
- `vfh` alias — mapped to `fzf-git-file-history`; will be replaced by a proper git-file-history FZF Script in issue 09

**Dead scripts to remove:**
- `vim-fzf-project-files` — superseded by the current Legacy FZF system, no callers
- `vim-fzf-git-file-history` — superseded by the current Legacy FZF system, no callers

The corresponding Legacy FZF autoloads for ctrl-h (`fzf-git-commits`, `fzf-git-commits-preview`)
and ctrl-j (`fzf-fs-directories-common`, and its source/options/prompt siblings) are also removed
since their only callers were the widgets being deleted.

## Acceptance criteria

- [ ] Ctrl-T keybinding widget deleted
- [ ] Ctrl-H keybinding widget deleted
- [ ] Ctrl-J keybinding widget deleted
- [ ] `vfh` alias deleted
- [ ] `vim-fzf-project-files` script deleted
- [ ] `vim-fzf-git-file-history` script deleted
- [ ] Legacy autoloads for git-commits deleted (no remaining callers)
- [ ] Legacy autoloads for fs-directories-common deleted (no remaining callers)
- [ ] `zshlint` passes on all modified files
