# PRD: ZSH Prompt PRD Progress Indicator

## Problem Statement

When working in a git worktree, the right prompt currently shows open GitHub issue count — information that is irrelevant to the feature being developed in that worktree. Worktrees used with the `ralph` workflow have a local `prd.json` file that tracks implementation progress (issues done vs. total). There is no way to see this progress at a glance from the terminal prompt.

Additionally, the branch-name-to-slug transformation is duplicated between `git-worktree-create` and wherever it would be needed in the prompt, and the prd.json parsing logic is duplicated between `ralph-end` and any new consumer. Both duplications create a risk of divergence.

## Solution

- Replace the GitHub issue count in the right prompt with a local PRD progress counter (`X/Y`) whenever the current directory is a worktree that has a `docs/<branch-slug>/prd.json`.
- Extract branch slugification and prd.json progress parsing into shared helpers used by all callers.
- Add a predicate `git-worktree-is-ralph` to centralize the "am I in a ralph worktree?" check.
- Keep GitHub issues and PRD progress as two independent prompt parts, each with its own guards — they never show simultaneously.

## User Stories

1. As a developer in a ralph worktree, I want to see `X/Y` in my right prompt, so that I know how many PRD issues are done without opening a file.
2. As a developer in a ralph worktree with all issues complete, I want to see `X/X` in green, so that I can immediately tell the feature is fully implemented.
3. As a developer in a ralph worktree with issues in progress, I want to see `X/Y` in yellow, so that I can distinguish "in progress" from "complete".
4. As a developer in a non-ralph worktree (no `prd.json`), I want the prompt to show nothing for PRD progress, so that my prompt is not cluttered.
5. As a developer in a worktree with a malformed or empty `prd.json`, I want to see a red error icon, so that I know the file exists but has a problem.
6. As a developer on `main` (not in a worktree), I want to continue seeing the GitHub issue count as before, so that my existing workflow is unchanged.
7. As a developer in a worktree without a `prd.json`, I want the GitHub issue count to be hidden (not shown), so that GitHub issues are never shown in a worktree context.
8. As a developer, I want `git-worktree-create feat/my-feature` and `ralph-directory` to produce consistent slugs for the same branch name, so that the prompt always finds the right `prd.json`.
9. As a developer, I want `ralph-end` to use the same prd.json parsing logic as the prompt, so that "PRD complete" detection is never out of sync with what the prompt shows.
10. As a developer running `ralph-progress` from any script or shell, I want to pass an optional directory argument, so that I can query progress for any ralph directory, not just the current worktree.
11. As a developer running `git-worktree-is-ralph` from any script or shell, I want to pass an optional path argument, so that I can query whether any path is a ralph worktree.
12. As a developer, I want `ralph-directory` to return an absolute path, so that callers can safely use it regardless of their current working directory.

## Implementation Decisions

### New module: `git-branch-slug`

Autoload function in the `git/branch/` namespace. Takes a branch name as argument, returns the filesystem-safe slug: all `/` replaced with `_`. No other transformation.

This is the single source of truth for branch-name-to-slug conversion. Both `git-worktree-create` and `ralph-directory` delegate to it.

### New module: `ralph-directory [path]`

Script in the `ralph` domain (`scripts/bin/ai/ralph/`), sibling of `ralph-end` and `ralph-progress`. Takes an optional path that is any subpath inside a worktree; defaults to `$PWD` if omitted.

Returns the **absolute path** to the ralph prd directory for that worktree: `<worktree-root>/docs/<branch-slug>/`.

Calls `git-worktree-is-ralph` internally. Exits 1 (returns nothing) if the path is not inside a worktree or if `prd.json` does not exist at the expected location. Only returns a path when the directory is confirmed to be a ralph worktree.

### New module: `ralph-progress [dir]`

Script in the `ralph` domain, sibling of `ralph-end`. Takes an optional directory (the ralph prd dir containing `prd.json`); if omitted, calls `ralph-directory` to deduce it.

Reads `prd.json` and outputs `done▮total` on stdout, where:
- `total` = number of items in the array
- `done` = number of items where `passes == true` (boolean strict)

Exits 1 if: `prd.json` is missing, unreadable, not a JSON array, or the array is empty.

Uses `jq` for parsing.

### New module: `git-worktree-is-ralph [path]`

Autoload function in the `git/worktree/` namespace. Takes an optional path (any subpath of a potential worktree); defaults to `$PWD`.

Exits 0 if the path is inside a linked git worktree AND the expected `docs/<branch-slug>/prd.json` exists at the worktree root. Exits 1 otherwise.

Uses `git-directory-is-worktree` directly (not the `GIT_DIRECTORY_IS_WORKTREE` env var) so it is callable outside the prompt context.

### Rename: `git_issues` → `git_issues_github`

The existing prompt part and its `OROSHI_PROMPT_PARTS` key are both renamed to `git_issues_github`. An early return is added: if `GIT_DIRECTORY_IS_WORKTREE == 1`, the part renders nothing. All references in `prompt/index.zsh` (async list, `oroshi-prompt-right`) are updated accordingly.

### New prompt part: `git_issues_prd`

Async prompt part registered at the same position as `git_issues_github` in `OROSHI_ASYNCHRONOUS_PROMPT_PARTS` and rendered in `oroshi-prompt-right` at the same slot.

Guard sequence:
1. Early return if `GIT_DIRECTORY_IS_REPOSITORY == 0`
2. Early return if `GIT_DIRECTORY_IS_WORKTREE == 0`
3. Early return if `git-worktree-is-ralph` exits 1 (no prd.json)
4. Call `ralph-progress`; if exit 1, render red error icon and return
5. Parse `done▮total` from output
6. Render `I done/total` in `COLOR_ALIAS_GIT_ISSUE` (yellow) if `done < total`
7. Render `I done/total` in `COLOR_ALIAS_SUCCESS` (green) if `done == total`

The `I` is a placeholder icon to be replaced by the user. All scripts and prompt functions that render an icon must define it as a local variable at the top (e.g. `local icon="I"`), so the glyph can be updated in one place without hunting through rendering logic.

No file cache — prd.json is local and fast to read.

### Updated: `git-worktree-create`

Replace the inline `${branch//\//_}` substitution with a call to `git-branch-slug`.

### Updated: `ralph-end`

Replace the inline `jq '[.[] | select(.status != "complete")] | length'` with a call to `ralph-progress`. Parse the `done▮total` output to determine if all issues are complete (`done == total`).

This also fixes the field name discrepancy: `ralph-end` was checking `.status != "complete"` while the canonical field is `passes == true`.

### Canonical prd.json schema

```json
[
  {
    "category": "string",
    "description": "string",
    "steps": ["string"],
    "passes": false
  }
]
```

`passes: true` is the sole completion signal. `null`, missing, or any other value counts as not complete.

## Testing Decisions

Good tests verify external behavior through the public interface only — not internal jq expressions, not intermediate variables. Each test sets up real filesystem state (real git worktrees, real prd.json files) and asserts on stdout/exit code.

Prior art: `scripts/bin/ai/ralph/__tests__/ralph-end.bats` and `ralph-state.bats` — these create temp state files and assert on behavior. The new tests follow the same pattern, using the existing bats helpers to create temporary git worktrees.

**Modules with tests:**

- `git-branch-slug` — input/output table: plain names, names with single slash, names with multiple slashes, names with hyphens
- `ralph-directory` — with no argument (PWD is inside worktree), with explicit path inside worktree, with path outside any worktree (expect exit 1), verify absolute path returned
- `ralph-progress` — valid prd.json with mixed passes, all passes true, all passes false, empty array (expect exit 1), malformed JSON (expect exit 1), missing file (expect exit 1), no argument (deduces from worktree context)
- `git-worktree-is-ralph` — inside ralph worktree (exit 0), inside worktree without prd.json (exit 1), outside any worktree (exit 1), with explicit path argument

**Modules without tests:**

- `git_issues_prd` — too coupled to the ZSH prompt rendering lifecycle to test in bats

## Out of Scope

- Displaying PRD progress outside the terminal prompt (e.g. in the Claude Code statusline or FZF pickers)
- Showing per-category breakdown or individual issue descriptions
- Modifying the prd.json file from the prompt
- Showing progress for worktrees that use a different prd schema (e.g. `status: "complete"`)
- Caching the prd.json parse result
- Supporting multiple prd.json files per worktree

## Further Notes

The `I` icon in `git_issues_prd` is a placeholder. The user will replace it with a Nerd Font glyph of their choice after implementation. Use `Edit` (not `Write`) when modifying files that contain Nerd Font / powerline glyphs to avoid silent UTF-8 stripping.
