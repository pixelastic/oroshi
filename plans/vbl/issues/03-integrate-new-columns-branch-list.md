## TLDR

Update `git-branch-list` to use the new 8-field raw format and introduce the new column layout — including worktree-aware data — without yet changing branch name colors.

## What to build

Update `git-branch-list` to:

1. Load `git-worktree-list-raw` at startup and build an associative array keyed by branch name, mapping each to its `dirty▮ahead▮behind` data.
2. For each branch, check the hash map to determine if it is a worktree branch.
3. Render the following column layout (same positions for all rows):

   | Col | Worktree branch | Non-worktree branch |
   |---|---|---|
   | 1 | pointer or empty | same |
   | 2 | branch name (standard colorize, no orange yet) | same |
   | 3 | dirty count (`±N`) if non-zero, else empty | remote name if non-default, else empty |
   | 4 | ahead vs main if non-zero, else empty | ahead vs remote |
   | 5 | behind vs main if non-zero, else empty | behind vs remote |
   | 6 | relative date | same |
   | 7 | short commit hash | same |
   | 8 | commit message | same |

Branch name rendering uses the existing `git-branch-colorize` call (no `--worktree` flag yet). The visual distinction between row types comes from the data columns only.

Write scaffold tests (`.scaffold.bats`) covering: worktree branch rows contain dirty/ahead/behind data, non-worktree rows contain remote distance data, column count is consistent.

## Acceptance criteria

- [ ] `vbl` loads worktree data at startup with no errors even when no worktrees exist
- [ ] Worktree branches show dirty count, ahead vs main, behind vs main in columns 3–5
- [ ] Non-worktree branches show remote name (if non-default) and ahead/behind vs remote in columns 3–5
- [ ] Date appears before commit hash for all rows
- [ ] All rows have the same number of columns
- [ ] Scaffold tests (`.scaffold.bats`) written and passing
