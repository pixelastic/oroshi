## PRD

[vws-completion/PRD.md](./PRD.md)

## What to build

Create a new autoload function `git-worktree-distance-raw` that takes a branch name as its sole argument and outputs `ahead▮behind` using the standard `▮` field separator. It runs `git rev-list --left-right --count "${branch}...main"` from the current directory (caller must be inside the git repo). Exits 1 if the rev-list fails (branch unknown, main missing, not in a repo).

Create a bats test file covering all meaningful behaviors.

## Acceptance criteria

- [ ] `git-worktree-distance-raw <branch>` outputs `0▮0` for a branch with no divergence from main
- [ ] Outputs the correct ahead count when the branch has commits not in main
- [ ] Outputs the correct behind count when main has commits not in the branch
- [ ] Exits 1 when called outside a git repo or with an unknown branch
- [ ] Uses `▮` as the field separator between ahead and behind
- [ ] Bats tests cover all four scenarios above

## Blocked by

None — can start immediately
