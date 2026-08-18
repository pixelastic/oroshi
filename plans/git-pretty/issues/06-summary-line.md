## TLDR

Styled summary line replaces the progress bar on push completion.

## What to build

When the push completes successfully, the TUI replaces the progress bar with a one-line summary:

`{icon} {coloredBranch} -> {coloredRemote}  {fromRef}..{toRef}`

- Icon: from `icons.json` (e.g. `git-branch-ahead` or similar push icon)
- Branch: colored using the resolved branch color from theme
- Remote: colored using the resolved remote color from theme
- Refs: short commit hashes from the parsed ref update line
- Styled with lipgloss

For "up to date" pushes: `{icon} {coloredBranch} -> {coloredRemote}  (up to date)`

Remote messages (like GitHub PR creation URLs) are printed on separate lines after the summary.

## Acceptance criteria

- [ ] Summary line appears after successful push
- [ ] Branch and remote names are colored per theme
- [ ] Commit range is displayed from parsed ref update
- [ ] "Up to date" variant works
- [ ] Remote messages (GitHub PR URLs) are passed through after summary
- [ ] Progress bar is no longer visible after completion
