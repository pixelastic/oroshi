## TLDR

Create `mark-delete`, `complete-marks`, and `_marks` compdef — marks-only deletion with marks-only completion.

## What to build

Create `tools/term/zsh/config/functions/autoload/misc/mark/mark-delete`:
1. Require one argument (mark name), error if missing
2. Check `$OROSHI_MARKPATH/$name` exists as symlink, error if not
3. Remove the symlink

Create `tools/term/zsh/config/functions/autoload/completion/complete-marks`:
- Call `mark-list-raw`, reformat output from `name▮path` to `name:path` (zsh completion format)
- Marks only — no projects

Create `tools/term/zsh/config/completion/compdef/_marks`:
- Compdef wrapper for `mark-delete`, calls `complete-marks`
- Same pattern as `_jumps` but uses `complete-marks` and a "Delete mark" header

Prior art: current `scripts/bin/unmark` for deletion logic, `_jumps` for compdef pattern.

## Behavioral Tests

**mark-delete removes a symlink:**
- given $OROSHI_MARKPATH/foo exists
- mark-delete foo removes it

**mark-delete errors on missing name:**
- mark-delete with no argument prints error

**mark-delete errors on nonexistent mark:**
- mark-delete unknown prints error

**complete-marks outputs marks only:**
- given marks and projects exist
- complete-marks outputs only mark entries

## Acceptance criteria

- [ ] `misc/mark/mark-delete` exists and is autoloadable
- [ ] Errors on missing argument and nonexistent mark
- [ ] `complete-marks` outputs only marks (no projects)
- [ ] `_marks` compdef serves `mark-delete`
- [ ] All behavioral tests pass
