## TLDR

Rename `handoff-end` to `sidequest-end` and move it into a new `sidequest/` folder.

## What to build

Move the companion script from `scripts/bin/ai/handoff/handoff-end` to `scripts/bin/ai/sidequest/sidequest-end`:

- Create the new `scripts/bin/ai/sidequest/` directory
- Copy the script, updating the internal comment that references `/handoff skill` → `/sidequest skill`
- Delete the old `scripts/bin/ai/handoff/` directory

The script logic itself is unchanged: it takes a file path argument, validates it exists, then pipes `@<path>` to `clipboard-write`.

## Acceptance criteria

- [ ] `scripts/bin/ai/sidequest/sidequest-end` exists and is executable
- [ ] Internal comment references `/sidequest skill`
- [ ] `scripts/bin/ai/handoff/` directory is deleted
- [ ] Running `sidequest-end <valid-path>` copies `@<path>` to clipboard without error
