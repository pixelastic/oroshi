## PRD

`docs/context-badge/PRD.md`

## What to build

Update the Claude Code statusline to use `context-badge`.

Replace the separate `project-by-path` + `project-colorize` call and `git-branch-current` + `git-branch-colorize` call with a single `context-badge` call (ANSI). The statusline already shows both project and branch — `context-badge` unifies them into one call with the correct powerline transition.

This issue is done in a separate worktree and merged last.

## Acceptance criteria

- [ ] Statusline shows Context Badge (project + branch when in worktree) as a single unit
- [ ] No separate branch call remains in the statusline
- [ ] Statusline is correct inside a Worktree (shows branch)
- [ ] Statusline is correct inside a Git Repo Main (no branch)

## Blocked by

- issue-002 (`context-badge` ANSI core)
