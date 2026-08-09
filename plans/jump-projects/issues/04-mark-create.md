## TLDR

Create `mark-create` — save current directory as a named symlink, warn if project exists.

## What to build

Create `tools/term/zsh/config/functions/autoload/misc/mark/mark-create`:
1. Name defaults to current dirname if no argument given
2. Remove existing mark if one exists with same name
3. Create symlink `$MARKPATH/$name` → `$PWD`
4. Before creating, check if any `PROJECTS[*:path]` resolves to the same directory — if so, print warning but still create the mark

Calls `projects-load-definitions` before checking.

Prior art: current `scripts/bin/mark` for symlink creation logic.

## Behavioral Tests

**mark-create with explicit name:**
- creates symlink $MARKPATH/myname → $PWD

**mark-create with no argument:**
- uses current dirname as mark name

**mark-create overwrites existing mark:**
- given $MARKPATH/foo already exists
- mark-create foo replaces it

**mark-create warns on project match:**
- given PROJECTS[myproject:path] resolves to $PWD
- mark-create myproject prints warning to stderr
- symlink is still created

**mark-create without project match:**
- no warning printed

## Acceptance criteria

- [ ] `misc/mark/mark-create` exists and is autoloadable
- [ ] Default name from dirname when no argument
- [ ] Overwrites existing mark silently
- [ ] Warns on stderr when directory matches a project path
- [ ] Creates symlink despite warning
- [ ] Creates `$MARKPATH` directory if missing
- [ ] All behavioral tests pass
