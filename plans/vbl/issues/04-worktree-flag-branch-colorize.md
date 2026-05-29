## TLDR

Add a `--worktree` flag to `git-branch-colorize` that renders the branch name with orange background, light text, and a closing powerline separator.

## What to build

Add a `--worktree` flag to `git-branch-colorize`. When passed:

- Render the branch name with `COLOR_ORANGE_7` background and `COLOR_ORANGE_1` foreground
- Append a closing powerline separator rendered in `COLOR_ORANGE_7` on transparent background (same pattern as the Worktree Segment in `context-badge`)
- Store the powerline character (U+E0B0) in a named local variable at the top of the function — never inline it as a literal — to prevent silent loss during file edits

The flag is explicit: the function never auto-detects whether a branch is a worktree. The caller decides. Existing call sites (including `git-worktree-list`) are unaffected.

Write scaffold tests (`.scaffold.bats`) covering: output with `--worktree` contains the branch name, output with `--worktree` differs from plain output (background codes present), plain output without `--worktree` is unchanged.

## Acceptance criteria

- [ ] `git-branch-colorize feat/x --worktree` produces ANSI output containing `feat/x`
- [ ] Output with `--worktree` contains background color escape codes absent from plain output
- [ ] Plain `git-branch-colorize feat/x` output is unchanged (no regression)
- [ ] `git-worktree-list` output is unchanged
- [ ] Powerline character is stored in a local variable, not inlined as a literal
- [ ] Scaffold tests (`.scaffold.bats`) written and passing
