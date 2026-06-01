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

**Dirty**:
A Worktree is dirty when it contains at least one file that is modified, added, deleted, or untracked — i.e. when `git status --porcelain` returns at least one line. A clean Worktree returns zero lines.
_Avoid_: modified, changed, has changes

**Dirty Count**:
The number of files contributing to a Worktree's dirty state — the line count of `git status --porcelain`. Displayed as a column in `vwl` with the `±` icon in violet (`COLOR_ALIAS_GIT_WORKTREE_DIRTY`). Hidden when zero.
_Avoid_: modified count, changed files count

## Relationships

- A **Worktree** belongs to exactly one **Git Repo Main**
- A **Worktree** has exactly one **Worktree Directory Name**, derived from the repo name and **Branch Slug**
- All **Worktrees** across all repos are stored in the **Worktrees Store**
- A **Git Repo Main** can have zero or more **Worktrees**

## Flagged ambiguities

- "worktree" was used to mean both any git working tree (including main) and only linked worktrees — resolved: **Worktree** means linked worktree only; the main repo directory is **Git Repo Main**.

## Decisions

### Global worktrees store shared across all repos

All worktrees, regardless of which repo they belong to, are created in a single directory (`$OROSHI_WORKTREES_DIR`). The alternative — a per-repo worktrees subfolder (siblings of the repo) — was rejected because it pollutes `~/local/www/projects/` and makes it impossible to get a global view of all work in progress. The global store keeps `projects/` clean.

### Deleting a worktree deletes its branch

`git-worktree-delete` removes both the worktree directory and its associated branch. A worktree is a working directory plus a branch — they form a single unit. Removing one without the other leaves a dangling branch that has no working context.

To guard against data loss, deletion is blocked if the branch has commits ahead of `main` (unmerged work). Pass `--force`/`-f` to bypass this check.

Previous decision (decoupled delete) was reversed after recognising that branches and worktrees are not parallel concepts: the worktree owns the branch.
