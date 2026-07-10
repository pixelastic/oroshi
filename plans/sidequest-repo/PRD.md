## Problem Statement

When asking Claude to create a sidequest targeting a different repo than the current working directory, the worktree is created in the wrong repo. The `sidequest` script has no way to target a repo other than the one at the current CWD.

Additionally, the `sidequest` / `sidequest-end` split is artificial: `sidequest-end` is never called directly from the terminal — it only exists to derive a slug from a filepath and forward to `sidequest`. This indirection adds complexity without benefit.

## Solution

Merge `sidequest-end` into `sidequest` so the script takes a filepath directly (slug derived from filename). Add an optional `--repo-dir <path>` flag: when provided, the script changes into that directory before creating the worktree, so the worktree is created in the correct repo.

Update the Claude skill to detect when a target repo is mentioned, resolve its path via `project-path`, and pass it as `--repo-dir`.

## User Stories

1. As a developer, I want to run `sidequest /tmp/oroshi/claude/sidequests/fix-bug.md` and have a worktree created in the current repo, so that the default behavior is unchanged.
2. As a developer, I want to run `sidequest /tmp/oroshi/claude/sidequests/fix-bug.md --repo-dir /path/to/other-repo` and have the worktree created in that repo, so that I can target any repo.
3. As a developer, I want an explicit error if `--repo-dir` points to a non-existent directory, so that I get a clear failure rather than a cryptic git error.
4. As a developer, I want an explicit error if `--repo-dir` points to a directory that is not a git repository, so that I get a clear failure.
5. As a developer using the sidequest skill, I want to say "make a sidequest in the oroshi repo" and have the worktree created in oroshi, so that I don't have to navigate repos manually.
6. As a developer using the sidequest skill, I want Claude to resolve "oroshi" to its filesystem path using `project-path`, so that any registered project name works.
7. As a developer, I want `sidequest-end` to be removed, so that there is a single entry point with a clear interface.
8. As a developer, I want the Kitty tab to always open without stealing focus, so that my current Claude session is not interrupted.
9. As a developer, I want `sidequest` to be listed in the hooks allowlist instead of `sidequest-end`, so that Claude can call it without a permission prompt.

## Implementation Decisions

- **Merged interface:** The new `sidequest` takes a filepath as its first argument. Slug is derived from the file's basename without extension (`${file:t:r}`). The `--prompt` and `--focus`/`--no-focus` flags are removed — the filepath is always used as the Claude prompt, and focus is always off.
- **`--repo-dir` flag:** Added via `zparseopts`. If provided: `cd` into the directory (failing fast if it does not exist via `set -e`), then call `git-directory-is-repository` to guard the non-git case with an explicit error message before proceeding.
- **Repo resolution in skill:** Step 1 of the skill is renamed from "Derive slug" to "Gather prerequisites." It collects both the slug (from conversation) and the target repo (if mentioned). Repo name is normalized by Claude from natural language, then resolved via `project-path <name>`. If `project-path` fails, Claude asks the user to clarify.
- **`sidequest-end` deleted:** The script and its test file are removed entirely. The allowlist entry `sidequest-end` is replaced with `sidequest`.
- **No standalone slug mode removed:** The previous `sidequest <slug>` interface (no file, no prompt) is dropped. The script now always requires a filepath.

## Testing Decisions

Good tests verify external behavior only — what the script does (collaborators called, exit codes) without testing internal implementation details like variable names or flag parsing internals.

**Module tested:** `sidequest` script (bats).

**Prior art:** existing `sidequest.bats` and `sidequest-end.bats`, which use `bats_mock` to stub collaborators (`git-worktree-create`, `git-worktree-path`, `kitty-tab-create`) and `bats_run_zsh` to invoke the script in a clean zsh subprocess.

**Test cases to cover:**
- No argument: exits with error
- File does not exist: exits with error
- Valid file: calls `git-worktree-create` with derived slug
- Valid file: calls `kitty-tab-create` with correct `--cwd` (worktree path) and `--cmd` (prompt filepath)
- `--repo-dir` with a non-existent path: exits with error
- `--repo-dir` with a non-git directory: exits with error (mock `git-directory-is-repository` → 1)
- `--repo-dir` with a valid git repo: calls `git-worktree-create` successfully (mock `git-directory-is-repository` → 0)

## Out of Scope

- Adding `--repo-dir` support to any other script beyond `sidequest`
- Resolving repo paths by any mechanism other than `project-path`
- Changing the worktree creation logic inside `git-worktree-create`
- Any UI changes to the Kitty tab (title, color, etc.)
- Support for repos not registered in the project definitions

## Further Notes

The `project-path` function (and `project-exists`) already exists in the zsh autoload library and is used by other scripts (`kitty-tab-create-interactive`, `context-root`). No new resolution infrastructure is needed.
