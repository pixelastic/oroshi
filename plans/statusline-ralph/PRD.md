## Problem Statement

The Claude Code status line provides real-time context (token usage, cost, model, MCP servers) but gives no visibility into Ralph plan progress for the active workspace. Developers using Ralph plans must switch context to check how many issues are done — the information is available in the ZSH prompt but absent from the status line.

## Solution

Add a Ralph plan progress segment to the Claude Code status line, displayed after the MCP servers section. When the current workspace has an active Ralph plan, the segment shows `icon done/total` (e.g. `⬡ 3/12`), using the same icon and color logic as the ZSH prompt's git plan progress segment. When no plan is active (or state.json is absent/malformed), the segment is silently omitted.

## User Stories

1. As a developer using Ralph, I want to see plan progress in the status line, so I can track how many issues are done without leaving my Claude Code session.
2. As a developer, I want the segment to be hidden when no plan is active, so the status line stays clean for workspaces without a Ralph plan.
3. As a developer, I want completed plans to display in green, so I can immediately recognize when all issues are done.
4. As a developer, I want in-progress plans to display in the same amber color as the ZSH prompt, so the visual language is consistent across my terminal.
5. As a developer, I want the status line to show only the current workspace's plan, so I am not confused by plans from other open worktrees.
6. As a developer, I want the segment to handle missing or malformed state.json silently, so the status line never errors out due to plan state issues.

## Implementation Decisions

- **Reuse existing scripts:** `plan-directory` and `plan-progress` are called as external collaborators; no logic is duplicated in the statusline.
- **Explicit directory resolution:** `plan-directory` is called with the workspace directory from stdin (not `$PWD`), ensuring correct resolution regardless of the statusline script's working directory.
- **Two-step call pattern:** `plan-directory` is called first; if it returns empty (no active plan), `plan-progress` is never called. This makes the guard explicit and avoids an unnecessary subprocess.
- **Silent failure:** Any non-zero exit from `plan-directory` or `plan-progress` results in the segment being silently omitted. No error icon is shown.
- **Stderr suppressed:** Both external calls suppress stderr to prevent contaminating the status line output.
- **Color logic:** `COLORS[success]` (green) when done equals total; `COLORS[git-issue]` (amber) otherwise — identical to the ZSH prompt segment.
- **Icon:** `ICONS[git-issue]` — same icon as the ZSH prompt segment.
- **Segment position:** After the MCP servers segment, before the final print.
- **Scope:** Current workspace only — matches ZSH prompt behavior.

## Testing Decisions

Good tests verify external behavior — what the status line outputs — not internal implementation details. Collaborators (`plan-directory`, `plan-progress`) are mocked via `bats_mock` rather than by reproducing filesystem state.

The statusline script is the module under test. Tests will cover:

- Progress segment shown with correct `icon done/total` format when a plan is active and in progress
- Green color applied when done equals total (plan complete)
- Segment silently omitted when `plan-directory` returns empty (no active plan)

The existing `colors-load-definitions` and `icons-load-definitions` stubs in `setup()` will be extended to include `COLORS[git-issue]`, `COLORS[success]`, and `ICONS[git-issue]`.

Prior art: existing `statusline.bats` — same pattern of stubbing collaborators in `setup()` or per-test, running `statusline_run`, and asserting on stripped ANSI output or raw escape codes.

## Out of Scope

- Showing plans across multiple worktrees (summary view)
- Error icon for malformed or missing state.json
- A `--dir` flag on `plan-progress` (not needed; `plan-directory` already accepts an explicit path)
- Any modifications to `plan-progress` or `plan-directory`

## Further Notes

The ZSH prompt's `oroshi-prompt-populate:git_plan_progress` function is the model for this segment. The statusline implementation mirrors its color/icon/format logic exactly.
