## PRD

`docs/context-badge/PRD.md`

## What to build

Update all FZF surfaces to use `context-badge` (ANSI) and `context-root`/`context-path`.

**`fzf-prompt-directory`**: replace `project-by-path` + `project-colorize` + manual path stripping with `context-badge` for the badge and `context-root`/`context-path` for the sub-path.

**`fzf-fs-shared-preview-header`**: replace the `project-by-path` + `project-key` + `eval`-based stripping dance with `context-badge` for the badge and `context-root`/`context-path` for the relative path.

**`fzf-claude-sessions-source-no-query`** and **`fzf-claude-sessions-preview`**: replace `project-by-path` + `project-colorize` with `context-badge`.

**`fzf-projects-source`**: replace `project-colorize $projectName` with `context-badge $projectName` (project name input → Project Badge only, no Worktree Badge).

## Acceptance criteria

- [ ] FZF file picker prompt shows Context Badge + sub-path relative to Context Root
- [ ] FZF preview header shows Context Badge + file path relative to Context Root
- [ ] FZF Claude session list shows Context Badge for each session's working directory
- [ ] FZF Claude session preview shows Context Badge for the session
- [ ] FZF projects list shows Project Badge per project (no Worktree Badge)
- [ ] No remaining calls to `project-by-path` in FZF functions

## Blocked by

- issue-002 (`context-badge` ANSI core)
- issue-001 (`context-root` / `context-path`)
