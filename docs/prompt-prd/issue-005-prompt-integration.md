## PRD

[PRD.md](./PRD.md)

## What to build

Wire the new helpers into the ZSH prompt.

Three changes in `prompt/git.zsh` and `prompt/index.zsh`:

**1. Rename `git_issues` → `git_issues_github`**
The existing function, its `OROSHI_PROMPT_PARTS` key, all entries in `OROSHI_ASYNCHRONOUS_PROMPT_PARTS`, and all references in `oroshi-prompt-right` are renamed. An early return is added: if `GIT_DIRECTORY_IS_WORKTREE == 1`, the part renders nothing.

**2. New prompt part `git_issues_prd`**
Async, registered at the same position as `git_issues_github` in the async list and rendered at the same slot in `oroshi-prompt-right`.

Guard sequence:
1. Early return if `GIT_DIRECTORY_IS_REPOSITORY == 0`
2. Early return if `GIT_DIRECTORY_IS_WORKTREE == 0`
3. Call `git-worktree-is-ralph`; early return if exit 1
4. Call `ralph-progress`; if exit 1, render error icon in `COLOR_ALIAS_ERROR` and return
5. Parse `done▮total`
6. Render `<icon> done/total` in `COLOR_ALIAS_GIT_ISSUE` (yellow) if `done < total`
7. Render `<icon> done/total` in `COLOR_ALIAS_SUCCESS` (green) if `done == total`

The icon is defined as a local variable at the top of the function (placeholder `I`, to be replaced by the user with a Nerd Font glyph).

No file cache — prd.json is local and fast to read.

## Acceptance criteria

- [ ] In a non-worktree repo: `git_issues_github` shows GitHub issue count, `git_issues_prd` shows nothing
- [ ] In a worktree without prd.json: `git_issues_github` shows nothing, `git_issues_prd` shows nothing
- [ ] In a ralph worktree with issues in progress: `git_issues_prd` shows `I done/total` in yellow
- [ ] In a ralph worktree with all issues complete: `git_issues_prd` shows `I done/total` in green
- [ ] In a ralph worktree with malformed prd.json: `git_issues_prd` shows red error icon
- [ ] Icon is defined as a local variable at the top of `git_issues_prd`
- [ ] `prompt/index.zsh` async list and `oroshi-prompt-right` reference `git_issues_github` and `git_issues_prd`

## Blocked by

- issue-002-git-worktree-is-ralph.md
- issue-004-ralph-progress.md
