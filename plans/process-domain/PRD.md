## Problem Statement

There is no readable way to inspect Linux process ancestry from the shell. Finding a process name, its parent, or walking the full parent chain requires ad-hoc `/proc` reads or `ps` incantations that are hard to remember and compose.

## Solution

A new `process` sub-domain under `system/` in the autoloaded functions tree, providing composable wrappers around `/proc` filesystem introspection. Three leaf functions handle atomic lookups (existence, name, parent PID), and two tree functions compose them to walk and display the full ancestor chain.

## User Stories

1. As a shell user, I want to check if a PID exists, so that I can guard before doing further introspection
2. As a shell user, I want to get a process name by PID, so that I can identify what a process is without memorizing `/proc` paths
3. As a shell user, I want to get a process's parent PID, so that I can walk the process hierarchy
4. As a shell user, I want to get the full ancestor chain of a process as machine-readable output, so that I can pipe it into other tools
5. As a shell user, I want to see a colored tree display of a process's ancestry, so that I can visually understand how a process was spawned
6. As a script author, I want `--reply` variants of name, parent, and tree-raw, so that I can avoid subshell overhead in hot paths
7. As a tool author, I want the raw output to use the standard separator convention, so that it composes with `table` and other display functions

## Implementation Decisions

- Sub-domain of `system/`, not top-level — process introspection is system-level
- Five functions: `process-exists`, `process-name`, `process-parent`, `process-tree-raw`, `process-tree`
- `process-exists` communicates via exit code (0/1), no `--reply` flag
- `process-name` and `process-parent` support `--reply` (sets `$REPLY`, no echo)
- `process-tree-raw` supports `--reply` and outputs `PID▮name` lines (self first, ancestors after, excludes PID 1)
- `process-tree` is the display function: tree connectors (`└──`), name in `executable` color (yellow), PID in `number` color (blue), PID shown in parentheses after name
- `process-tree` calls `colors-load-definitions` explicitly
- `process-name` reads `/proc/PID/comm` (15-char truncation accepted)
- `process-parent` reads field 4 from `/proc/PID/stat`
- Missing PID → return 1, no output (for all functions)
- All functions use `setopt local_options err_return`
- Remove the `process` color key from the theme; replace its one usage in completion styling with `executable`

## Testing Decisions

- Good tests verify external behavior (output format, exit codes, tree structure), not implementation details (which `/proc` file was read)
- One `.bats` file per function
- `process-exists`, `process-name`, `process-parent`: integration tests against live `/proc` using `$$` (always `bash` in bats) and bogus PIDs
- `process-tree-raw`: integration tests using a chain of scripts with distinct interpreters (`zsh` → `bash` → `python3`) created inline in `setup()`, so the ancestor chain is deterministic and verifiable
- `process-tree`: mock `process-tree-raw` via `bats_mock` to get deterministic output, assert tree formatting and ANSI coloring via `bats_strip_ansi`
- Prior art: `git-worktree-list-raw.bats` (integration), `git-worktree-list.bats` (mocked display)

## Out of Scope

- Reading full command lines (`/proc/PID/cmdline`) — `/proc/PID/comm` is sufficient for now
- Child process discovery (walking down the tree)
- Signal sending or process management
- Process filtering or search

## Further Notes

- The `process` color key in the theme is removed as part of this work; its only usage (completion styling for "Running processes") switches to `executable`
- The theme dist file must be rebuilt after the color key removal
