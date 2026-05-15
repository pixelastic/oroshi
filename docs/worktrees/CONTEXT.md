# Git Worktree Toolbox

A set of zsh functions and aliases for managing git linked worktrees — creating, navigating, listing, and deleting them — with shell prompt integration.

## Language

**Worktree**:
A linked git worktree: a temporary separate directory on disk checked out to a specific branch, created via `git-worktree-create`. Exists for the duration of a feature or fix, then deleted. Deleting a Worktree does NOT delete the associated branch — these are decoupled operations.
_Avoid_: linked worktree, workspace, working tree

**Git Repo Main**:
The original repository directory — always on the `main` branch. The source from which worktrees are forked. When following this workflow, feature/fix work always happens in a Worktree, never in the Git Repo Main.
_Avoid_: main worktree, origin repo, parent repo

**Branch Slug**:
The filesystem-safe transformation of a branch name used in worktree directory names. Replaces `/` with `_`.
_Example_: `fix/login-bug` → `fix_login-bug`
_Avoid_: branch name, sanitized branch

**Worktree Directory Name**:
The name of a worktree folder on disk: `<repo-name>--<branch-slug>`.
_Example_: `firost--fix_login-bug`

**Worktrees Store** (`$OROSHI_WORKTREES_DIR`):
The single directory on disk where all worktrees live, regardless of which repo they belong to. Defined as an environment variable.
_Avoid_: worktrees folder, worktrees root

**Repo Name**:
The human-readable name of a git repository, used as the prefix in Worktree Directory Names. Derived from the GitHub remote URL when available (e.g. `git@github.com:pixelastic/oroshi.git` → `oroshi`); falls back to the folder name with leading dots stripped (e.g. `.oroshi` → `oroshi`).
_Avoid_: directory name, folder name

## Relationships

- A **Worktree** belongs to exactly one **Git Repo Main**
- A **Worktree** has exactly one **Worktree Directory Name**, derived from the repo name and **Branch Slug**
- All **Worktrees** across all repos are stored in the **Worktrees Store**
- A **Git Repo Main** can have zero or more **Worktrees**

## Flagged ambiguities

- "worktree" was used to mean both any git working tree (including main) and only linked worktrees — resolved: **Worktree** means linked worktree only; the main repo directory is **Git Repo Main**.
