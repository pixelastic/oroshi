# Context

Functions that resolve "where you are" on the filesystem — combining project identity with optional worktree awareness.

## Domain structure

- `context/` — context-level functions (`context-badge`, `context-path`, `context-raw`, `context-root`)
- `context/project/` — project-level functions (`project-exists`, `project-name`, `project-path`, `project-remove`, `projects-build`, `projects-load-definitions`)

## Language

**Project**:
A registered codebase with a name, root path, icon, and color scheme. Defined in `theming/src/projects.json`; loaded into the `PROJECTS` associative array via `projects-load-definitions`.
_Avoid_: workspace, repo (too git-specific)

**Context**:
A Project combined with an optional Worktree — represents "where you are right now" on the filesystem. A Context is project-aware and worktree-aware. Two people in the same Project but different Worktrees are in different Contexts. In a submodule-in-worktree, the Context resolves to the parent worktree's project and branch.
_Avoid_: project context, working context

**Context Root**:
The most specific enclosing directory for a given path: the Worktree root if the path is inside a Worktree, otherwise the Project root path. In a submodule-in-worktree, returns the superproject worktree root, not the submodule root. Also the name of the function `context-root <path>` that returns it.
_Example_: `~/worktrees/oroshi--fix/src/components/` → `~/worktrees/oroshi--fix/`
_Avoid_: base path, root directory

**Context Badge**:
The complete colored string representing a Context. Contains a Project Segment always, and a Worktree Segment when the path is inside a Worktree.
_Example_: `[ x oroshi ▶][ git-commit-message ▶]`
_Avoid_: project badge, project label, project prefix, project display

**Context Path**:
The filesystem path expressed relative to the Context Root. Not simplified — pass to `simplify-path` for display truncation. In a submodule-in-worktree, includes the submodule directory (e.g. `private/config/src/` rather than just `src/`). Also the name of the function `context-path <path>` that returns it.
_Example_: `~/worktrees/oroshi--fix/src/components/` → `src/components/`
_Avoid_: relative path, sub-path, sub-directory

**Context Raw**:
Internal primitive that resolves a path to a `project▮branch▮root` triple, using U+25AE (`▮`) as separator. Branch is the raw Git branch name (not slugified), empty when not in a worktree. Used by `context-root`, `context-path`, and `context-badge` to avoid redundant detection. Also the name of the function `context-raw <path>` that returns it.
_Example_: `context-raw ~/worktrees/oroshi--fix/src/` → `oroshi▮fix/something▮~/worktrees/oroshi--fix`
_Avoid_: context tuple, context triple

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
- `context-raw` is the shared resolution primitive — `context-root`, `context-path`, and `context-badge` all derive their values from its `project▮branch▮root` output
- In a submodule-in-worktree, all context functions resolve against the superproject worktree, not the submodule — the submodule directory becomes part of the Context Path
- Passing a project name to `context-badge` is equivalent to passing its root path — a Project root is always a Git Repo Main, never a Worktree, so the result contains no Worktree Segment

## Flagged ambiguities

- "project label", "project prefix", "project display" were used informally — resolved: the canonical term is **Context Badge**
- "Project Segment" / "Worktree Segment" were used for the two blocks — resolved: **Project Badge** and **Worktree Badge** are the canonical terms; they are conceptual parts, not separate functions
- `project-colorize` (takes a project name) was used as the public interface everywhere — resolved: `context-badge` is the single public entry point
- "Project" was overloaded to mean both the registered entity and the current location — resolved: **Project** = registered entity, **Context** = current location (project + worktree)
