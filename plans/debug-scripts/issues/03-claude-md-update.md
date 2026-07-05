## TLDR

Replace the inline throw-away scripts documentation in `~/CLAUDE.md` with a pointer to the `debug-script` skill.

## What to build

Edit the `## Throw-away scripts` section in `/home/tim/CLAUDE.md`. Replace its current content (folder path, jq/jo rules) with a single directive telling Claude to use the `debug-script` skill when it needs to write a complex Bash command.

The section heading should be preserved. The jq/jo rules currently in the section should be moved under `## Code` or kept if they belong here — check whether they are better placed elsewhere.

## Behavioral Tests

Skipped — documentation file.

## Scaffolding Tests

Skipped — no structural transformation.

## Acceptance criteria

- [ ] `## Throw-away scripts` section no longer contains the inline pattern description
- [ ] Section contains a directive to use the `debug-script` skill
- [ ] The jq/jo rules are either preserved here or moved to an appropriate location (not lost)
- [ ] No other section of `~/CLAUDE.md` is modified
