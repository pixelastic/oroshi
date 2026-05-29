## TLDR

Verify no live image scripts reference `img/__legacy/` contents, then delete the folder with human sign-off.

## What to build

This is a HITL (human-in-the-loop) issue. The agent does the analysis; the human makes the deletion decision.

**Step 1 — enumerate**: List every script and library name inside `img/__legacy/` (both `bin/` and `lib/`).

**Step 2 — grep**: Search for references to each of those names across:
- All active image scripts (outside `__legacy/`)
- All ZSH autoload functions

**Step 3 — report**: Present findings to the user:
- For each file in `__legacy/`: is it referenced anywhere? Where?
- If references exist: are those referencing scripts themselves useful or dead?

**Step 4 — human decision**: User decides whether to:
- Delete `img/__legacy/` entirely (if no live references, or all references are also dead)
- Exclude specific files from deletion
- Cascade-delete any referencing scripts that are also dead

**Step 5 — act**: Execute the deletion as decided. Remove any empty parent directories.

## Acceptance criteria

- [ ] All file names in `img/__legacy/` (bin/ and lib/) have been grepped across the live codebase
- [ ] A reference report has been presented to the user
- [ ] User has given explicit sign-off on what to delete
- [ ] Agreed deletions have been executed
- [ ] No active, useful script is left with a broken reference
