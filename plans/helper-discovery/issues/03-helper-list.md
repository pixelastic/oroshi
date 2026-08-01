## TLDR

Create `helper-list` autoload function — colorized wrapper around `helper-list-raw`.

## What to build

New autoload function at `tools/term/zsh/config/functions/autoload/misc/helper-list`.

Behavior:
- Pass all arguments through to `helper-list-raw`
- For each output line, split on `▮`
- Colorize the name field in yellow (executable color) using `colorize`
- Colorize the description field with `$COLORS[comment]`
- Align output into columns (follow existing list patterns for column alignment)

Follow the established `*-list` wrapper pattern (e.g. `git-branch-list`, `skills-list`).

No tests — pure presentation.

## Acceptance criteria

- [ ] Function loads and runs without error
- [ ] Calls `helper-list-raw` with same arguments
- [ ] Name displayed in yellow/executable color
- [ ] Description displayed in comment color
- [ ] Output is column-aligned
