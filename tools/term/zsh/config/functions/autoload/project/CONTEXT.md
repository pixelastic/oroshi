# Project Display

Functions that resolve and render a project's visual identity from a filesystem path.

## Language

**Project**:
A registered codebase with a name, root path, icon, and color scheme. Defined via `PROJECT_<KEY>_*` environment variables in `theming/env/projects.zsh`.
_Avoid_: workspace, repo (too git-specific)

**Context**:
A Project combined with an optional Worktree — represents "where you are right now" on the filesystem. A Context is project-aware and worktree-aware. Two people in the same Project but different Worktrees are in different Contexts.
_Avoid_: project context, working context

**Context Root**:
The most specific enclosing directory for a given path: the Worktree root if the path is inside a Worktree, otherwise the Project root path. Also the name of the function `context-root <path>` that returns it.
_Example_: `~/worktrees/oroshi--fix/src/components/` → `~/worktrees/oroshi--fix/`
_Avoid_: base path, root directory

**Context Badge**:
The complete colored string representing a Context. Contains a Project Segment always, and a Worktree Segment when the path is inside a Worktree.
_Example_: `[ x oroshi ▶][ git-commit-message ▶]`
_Avoid_: project badge, project label, project prefix, project display

**Context Path**:
The filesystem path expressed relative to the Context Root. Not simplified — pass to `simplify-path` for display truncation. Also the name of the function `context-path <path>` that returns it.
_Example_: `~/worktrees/oroshi--fix/src/components/` → `src/components/`
_Avoid_: relative path, sub-path, sub-directory

**Project Badge**:
The left block of a Context Badge. Always present. Contains the project icon, name (unless hidden), and a powerline arrow in the project's background color. Not a separate function — the powerline transition color couples it to the Worktree Badge and both are rendered together inside `context-badge`.
_Avoid_: project segment, project part, project block

**Worktree Badge**:
The right block of a Context Badge. Present only when the path is inside a Worktree. Contains the branch name and powerline arrow, rendered on `$COLOR_ALIAS_GIT_BRANCH` background with white text. Not a separate function — its background color determines the foreground color of the Project Badge's trailing arrow.
_Avoid_: worktree segment, branch badge, branch block

## Relationships

- A **Context** has exactly one **Project** and zero or one **Worktrees**
- A **Context Badge** always contains exactly one **Project Badge**
- A **Context Badge** contains a **Worktree Badge** if and only if the path is inside a Worktree
- A **Context Path** is always relative to the **Context Root**
- `context-root <path>` + `context-path <path>` = original path (they partition a full path)
- Passing a project name to `context-badge` is equivalent to passing its root path — a Project root is always a Git Repo Main, never a Worktree, so the result contains no Worktree Segment

## Flagged ambiguities

- "project label", "project prefix", "project display" were used informally — resolved: the canonical term is **Context Badge**
- "Project Segment" / "Worktree Segment" were used for the two blocks — resolved: **Project Badge** and **Worktree Badge** are the canonical terms; they are conceptual parts, not separate functions
- `project-colorize` (takes a project name) was used as the public interface everywhere — resolved: `context-badge` is the single public entry point
- "Project" was overloaded to mean both the registered entity and the current location — resolved: **Project** = registered entity, **Context** = current location (project + worktree)
