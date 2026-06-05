## TLDR

Modify `sidequest-end` to call `sidequest` instead of writing to the clipboard.

## What to build

Simplify `sidequest-end` to a thin wrapper:
1. Extract the Sidequest Slug from the filepath basename (strip `.md`)
2. Call `sidequest <slug> --prompt @<filepath> --no-focus`
3. Remove all clipboard logic

Update the existing tests from issue 03 to cover the new behavior.

## Behavioral Tests

Mock immediate collaborator: `sidequest`.

**Error handling**
- exits with an error when called with no argument
- exits with an error when the given file does not exist

**Happy path**
- calls `sidequest` with the slug extracted from the filepath, `--prompt @<filepath>`, and `--no-focus`

## Scaffolding Tests

Lives in `plans/sidequest/scaffold/05-sidequest-end-update.bats`. Removed once plan is archived.

- `clipboard-write` is never called

## Acceptance criteria

- [ ] `sidequest-end` no longer calls `clipboard-write`
- [ ] `sidequest-end /tmp/oroshi/claude/sidequests/fix-ralph.md` calls `sidequest fix-ralph --prompt @/tmp/oroshi/claude/sidequests/fix-ralph.md --no-focus`
- [ ] All behavioral tests in `__tests__/sidequest-end.bats` pass
- [ ] Scaffolding test in `scaffold/05-sidequest-end-update.bats` passes
