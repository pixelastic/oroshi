## TLDR

Create `mark-jump` — resolve project or mark name to a directory and cd into it.

## What to build

Create `tools/term/zsh/config/functions/autoload/misc/mark/mark-jump` — an autoloaded function that takes a name argument and cd's into the matching directory.

Resolution order:
1. Check `PROJECTS[$1:path]` — if set, cd to `${~projectPath}` (tilde expansion)
2. Check `$OROSHI_MARKPATH/$1` — if exists, cd via symlink (`cd -P`)
3. Print error "No such mark: $1"

Calls `projects-load-definitions` before checking PROJECTS.

## Behavioral Tests

**mark-jump resolves a project:**
- given PROJECTS[foo:path]=~/some/dir and no mark named foo
- mark-jump foo cd's to the expanded project path

**mark-jump resolves a mark:**
- given a symlink $OROSHI_MARKPATH/bar pointing to /tmp/target and no project named bar
- mark-jump bar cd's to /tmp/target

**mark-jump prefers project over mark on collision:**
- given both PROJECTS[baz:path] and $OROSHI_MARKPATH/baz exist
- mark-jump baz cd's to the project path, not the mark

**mark-jump errors on unknown name:**
- given no project or mark named qux
- mark-jump qux prints error and exits non-zero

## Acceptance criteria

- [ ] `misc/mark/mark-jump` exists and is autoloadable
- [ ] Projects resolve first, marks second
- [ ] Tilde in project paths is expanded via `${~var}`
- [ ] Error message on unknown name
- [ ] All behavioral tests pass
