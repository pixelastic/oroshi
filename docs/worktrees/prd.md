# PRD — Git Worktree Toolbox

## Problem Statement

Working on multiple branches in parallel requires either stashing work or cloning the repo multiple times. There is no ergonomic way to create an isolated working directory per branch, navigate between them, or know at a glance whether the current shell is inside a Worktree or the Git Repo Main.

## Solution

A suite of zsh functions and aliases that wraps git's linked worktree feature with ergonomic creation, navigation, listing, and deletion. A prompt integration visually signals when the shell is inside a Worktree. All Worktrees are stored in a central Worktrees Store (`$OROSHI_WORKTREES_DIR`), separate from the project repos.

## User Stories

1. As a developer, I want to create a Worktree for an existing branch so that I can work on it in isolation without stashing.
2. As a developer, I want to create a Worktree for a new branch in one command so that I don't have to create the branch and Worktree separately.
3. As a developer, I want the shell to automatically cd into a newly created Worktree so that I can start working immediately.
4. As a developer, I want Worktree creation to be idempotent so that re-running the command doesn't fail if the Worktree already exists.
5. As a developer, I want autocompletion on all local branches when creating a Worktree so that I don't have to type full branch names.
6. As a developer, I want Worktree directory names to follow `<repo>--<branch-slug>` so that I can identify repo and branch at a glance.
7. As a developer, I want branch name slashes converted to underscores in directory names so that the path is valid and I can distinguish slashes from dashes.
8. As a developer, I want all Worktrees stored in a single global `$OROSHI_WORKTREES_DIR` so that my `projects/` folder stays clean.
9. As a developer, I want to list the Worktrees of the current repo so that I can see what work is in progress.
10. As a developer, I want to switch to any Worktree of the current repo with autocompletion so that I can navigate without typing paths.
11. As a developer, I want `main` to appear in switch autocompletion so that I can return to the Git Repo Main without using `j`.
12. As a developer, I want to delete a Worktree without deleting its branch so that I can clean up the directory while keeping the branch.
13. As a developer, I want deleting a Worktree from inside it to first cd to the Git Repo Main so that my shell isn't left in a deleted directory.
14. As a developer, I want my shell prompt to display a special icon when I'm inside a Worktree so that I always know my context at a glance.
15. As a developer, I want `git-directory-is-worktree` as a boolean primitive so that other functions and the prompt can rely on it.
16. As a developer, I want `git-worktree-main` to return the Git Repo Main path from anywhere so that navigation and deletion always have a reference point.

## Implementation Decisions

See individual issue files for module-level detail.

**Aliases:**
| Alias | Function |
|-------|----------|
| `vwtc` | `git-worktree-create` |
| `vwtl` | `git-worktree-list` |
| `vwts` | `git-worktree-switch` |
| `vwtR` | `git-worktree-delete` |

**ADRs:** `docs/worktrees/adr/0001` (global store), `docs/worktrees/adr/0002` (delete decoupled from branch delete)

## Testing Decisions

All modules implemented TDD: failing BATS test first, then implementation. Tests live in `scripts/bin/__tests__/`. Test only observable behavior (output, exit code, filesystem side effects) — not internals.

## Out of Scope

- Deleting the branch on `git-worktree-delete` (ADR 0002)
- Global Worktree list across all repos
- Autocompletion on remote branches for `vwtc`
- Confirmation prompt on `vwtR`
