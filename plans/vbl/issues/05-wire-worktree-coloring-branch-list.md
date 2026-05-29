## TLDR

Call `git-branch-colorize --worktree` for worktree branches in `git-branch-list` so they render in orange with the powerline separator.

## What to build

In `git-branch-list`, replace the unconditional `git-branch-colorize "$branchName" --with-icon` call with a conditional:

- If the branch is in the worktree hash map → call `git-branch-colorize "$branchName" --worktree`
- Otherwise → call `git-branch-colorize "$branchName" --with-icon` (unchanged)

This is the final slice. After it, `vbl` shows worktree branches highlighted in orange with the powerline separator, and non-worktree branches in their standard style.

Update scaffold tests from issue 03 (`.scaffold.bats`) to additionally assert that worktree branch rows contain orange background escape codes in the branch name cell, and non-worktree rows do not.

## Acceptance criteria

- [ ] Worktree branches appear with orange background and powerline separator in `vbl` output
- [ ] Non-worktree branches appear with standard colorize (no orange background)
- [ ] The current branch pointer (``) still appears correctly for the active branch regardless of worktree status
- [ ] Scaffold tests (`.scaffold.bats`) updated and passing
- [ ] `vbl` runs without errors when no worktrees exist
