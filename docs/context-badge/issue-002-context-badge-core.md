## PRD

`docs/context-badge/PRD.md`

## What to build

New autoload function **`context-badge <path|name>`** (ANSI output only — no `--zsh` flag yet, that is issue-003).

Accepts either a registered project name or a filesystem path. If the argument matches a known project name it is resolved to that project's root path first.

Always renders a **Project Badge** (icon + name + powerline arrow in project colors). When the resolved path is inside a linked Worktree, appends a **Worktree Badge** (branch name on `$COLOR_ALIAS_GIT_BRANCH` background, white text, trailing powerline arrow). The powerline arrow that connects the two badges transitions color: the Project Badge's trailing arrow uses the Worktree Badge's background color as its foreground. This color transition is handled inside `context-badge` — the two blocks cannot be rendered independently.

Worktree detection is live (git commands on the given path, not cached env vars).

Returns empty string for a path outside all known projects.

Write BATS tests:
- path inside registered project (Git Repo Main) → contains project name, no branch visible
- path inside a Worktree → contains both project name and branch name
- project name as argument → same output as passing the project's root path
- path outside all known projects → empty output
- output contains raw ANSI escape sequences (not `%K{` zsh codes)

## Acceptance criteria

- [ ] Project Badge always present when project is known
- [ ] Worktree Badge appended (with branch name) when inside a linked Worktree
- [ ] No Worktree Badge when inside a Git Repo Main or non-git project
- [ ] Powerline arrow between badges uses Worktree Badge background as its foreground color
- [ ] Project name argument produces same output as the project's root path
- [ ] Empty output for unregistered paths
- [ ] Output is raw ANSI (no `%K{` codes)
- [ ] All acceptance criteria covered by BATS tests

## Blocked by

- issue-001 (needs `context-project` to resolve name → path)
