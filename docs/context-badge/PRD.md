## Problem Statement

When working inside a git Worktree, no single place in the shell environment reliably shows "which project, which worktree" together. The prompt, the Claude Code statusline, FZF pickers, and file preview headers each independently build their own project display string — using different code, different levels of worktree-awareness, and inconsistent visual results. Changing the display of a project requires touching many unrelated files. Worktree context is missing entirely from most of these surfaces.

## Solution

Introduce a unified vocabulary and a small set of functions that centralise all project+worktree display logic. Any surface that needs to show "where you are" calls a single function (`context-badge`) and gets a consistent, worktree-aware, powerline-styled string back. Changing the display means changing one place.

Two additional helpers (`context-root`, `context-path`) give callers the building blocks they need to strip and display sub-paths relative to the current context.

## User Stories

1. As a developer in a Worktree, I want my shell prompt to show the project name followed by the branch name, so that I always know which Worktree I am in at a glance.
2. As a developer in a Git Repo Main, I want my prompt to show only the project name (no branch block), so that the prompt stays compact when no Worktree is active.
3. As a developer in a non-git project directory (e.g. home), I want my prompt to show the project badge without any branch block, so that the display is consistent with the Git Repo Main case.
4. As a developer, I want the project and branch blocks to be visually connected via a powerline arrow that transitions seamlessly between their background colors, so that the badge reads as a single unit.
5. As a developer launching a FZF file picker, I want the prompt to show the Context Badge followed by the sub-path within the context, so that I always know where I am searching.
6. As a developer browsing FZF file previews, I want the preview header to show the Context Badge and the path relative to the context, so that file locations are easy to read.
7. As a developer viewing Claude Code sessions in FZF, I want each session entry to show the Context Badge for the session's working directory, so that I can identify which project and worktree a session belongs to.
8. As a developer, I want the Claude Code statusline to show the Context Badge for the current directory, replacing the current separate project + branch display, so that the statusline reflects full worktree context.
9. As a developer browsing a FZF list of all known projects, I want each entry to show the Project Badge for that project (no Worktree Badge), so that the list shows project identities rather than my current location.
10. As a developer, I want to call `context-badge` with either a project name or a filesystem path and get the same result, so that callers are not forced to resolve names to paths themselves.
11. As a developer, I want `context-root` to return the Worktree root when I am inside a Worktree, and the Project root otherwise, so that I have a reliable single function to find my enclosing context boundary.
12. As a developer, I want `context-path` to return the path relative to the Context Root, so that I can display meaningful sub-paths without manually computing the stripping.
13. As a developer, I want to obtain a Context Badge in zsh prompt format (using `%F{}`/`%K{}` codes) by passing `--zsh`, and in raw ANSI format by default, so that the same function works in both prompt and non-prompt contexts.
14. As a developer maintaining this codebase, I want a single function to update when the visual style of project or worktree display changes, so that all surfaces stay in sync automatically.

## Implementation Decisions

### New functions

**`context-badge <path|name> [--zsh]`** — the single public entry point for all project+worktree display. Accepts either a project name or a filesystem path. If the argument matches a known project name, it is expanded to that project's root path. Detects whether the resolved path is inside a Worktree by running git detection on that path directly (no dependency on cached env vars). Renders a Project Badge always; appends a Worktree Badge when a Worktree is detected. The `--zsh` flag makes the function set `OROSHI_IS_PROMPT=1` internally so that downstream rendering functions (`project-colorize`, `colorize`) emit zsh prompt codes instead of raw ANSI. The powerline arrow color transitioning between Project Badge and Worktree Badge is handled entirely inside this function — the two blocks cannot be rendered independently because the Project Badge's trailing arrow must use the Worktree Badge's background color as its foreground.

**`context-root <path>`** — returns the Context Root for a given path: the Worktree root if the path is inside a Worktree, otherwise the Project root. Returns empty string if the path belongs to no known project.

**`context-path <path>`** — returns the path relative to the Context Root. Strips the Context Root prefix from the given path. Does not simplify — callers pass the result to `simplify-path` if needed.

### Project Badge and Worktree Badge are conceptual, not functions

The Project Badge (left block: icon + name + powerline arrow in project colors) and the Worktree Badge (right block: branch + powerline arrow on `$COLOR_ALIAS_GIT_BRANCH` background, white text) are sub-parts of the Context Badge rendered by a single function. They are named in the domain glossary for clarity but have no corresponding functions.

### Public API of the `context` domain

| Function | Role | Status |
|---|---|---|
| `context-badge` | path or name → full Context Badge | New |
| `context-root` | path → Context Root path | New |
| `context-path` | path → sub-path relative to Context Root | New |
| `context-project` | path → project name | New — replaces `project-by-path` |
| `project-key` | project name → env var key | Kept — NeoVim depends on it directly |
| `project-colorize` | internal rendering helper | Not public |
| `project-exists` | internal lookup | Not public |
| `project-path` | internal — project name → root path | Not public |
| `project-by-path` | **deleted** | Replaced by `context-project` |

### Callers updated

- **Prompt `path`**: replaces `project-colorize` call with `context-badge --zsh`. The `git_worktree_branch` asynchronous prompt part is removed — the branch is now rendered synchronously inside `context-badge` as part of `path`.
- **Prompt `path_worktree_dir`**: continues to show the Context Path after the badge. Uses `context-root` / `context-path` for path stripping instead of the previous manual dance.
- **Claude Code statusline**: replaces the separate project + `git-branch-colorize` calls with a single `context-badge` call.
- **FZF prompt helpers** (`fzf-prompt-directory`, `fzf-fs-shared-preview-header`): replace the `project-by-path` + `project-key` + `eval` stripping dance with `context-badge` for the badge and `context-root`/`context-path` for sub-path stripping.
- **FZF Claude session source and preview**: replace `project-by-path` + `project-colorize` with `context-badge`.
- **FZF projects source**: replaces `project-colorize $projectName` with `context-badge $projectName` — project name input is valid and produces a badge with no Worktree Badge.
- **NeoVim `statusline.lua`**: replaces `project-by-path` shell call with `context-project`.

### Worktree detection is always live

`context-badge`, `context-root`, and `context-path` detect worktree status from the given path directly (via git commands on that path), not from cached env vars (`$GIT_DIRECTORY_IS_WORKTREE`). This keeps the functions self-contained and correct when called with a path other than `$PWD`.

## Testing Decisions

Good tests verify observable output from a given input path, not internal branching logic. Tests should cover: what the rendered string contains (project name present, branch present/absent, powerline arrows), not how it was assembled.

**`context-badge`** is the only new function with BATS tests. It is the deep module — it encapsulates the most logic and has the most to break. Callers are not tested independently; their changes are shallow call replacements.

Test cases for `context-badge`:
- Given a path inside a registered project (Git Repo Main): output contains project name, no branch
- Given a path inside a Worktree: output contains project name and branch name
- Given a project name directly: same result as its root path
- Given a path outside any known project: output is empty
- With `--zsh`: output contains `%K{` codes; without: output contains ANSI escape sequences

Prior art: `scripts/bin/__tests__/git-worktree-project.bats`, `scripts/bin/__tests__/oroshi-prompt-path-worktree.bats` — both use `run zsh -c` with inline env var overrides to test autoload functions that depend on project or git state.

## Out of Scope

- **NeoVim statusline**: the NeoVim statusline has its own Lua implementation that reads project variables directly. Integrating `context-badge` output into Lua is a separate issue.
- **Kitty tab labels**: tab naming is manual and not driven by the context system.
- **`git-branch-colorize`, `git-tag-colorize`, `git-remote-colorize`**: these functions also use `OROSHI_IS_PROMPT=1` as an env var interface. Migrating them to a `--zsh` flag is a separate concern.
- **`simplify-path`**: no changes to this function. Callers that want a simplified Context Path call `simplify-path "$(context-path $path)"`.

## Further Notes

The domain glossary lives in `config/term/zsh/functions/autoload/project/CONTEXT.md` (path subject to change if the domain is reorganised — see below). It defines all terms used in this PRD: Context, Context Badge, Project Badge, Worktree Badge, Context Root, Context Path. This file is committed to the repository permanently. The PRD itself (`docs/context-badge/`) will be deleted once the implementation is complete.
