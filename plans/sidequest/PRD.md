## Problem Statement

Launching a sidequest from Claude Code requires too many manual steps: after the `/sidequest` skill creates the context document, the user must manually open a new Kitty tab, create a Worktree, navigate into it, and launch Claude with the file path pasted from the clipboard. This friction discourages the use of sidequests for focused work.

## Solution

Automate the full sidequest launch flow. When the `/sidequest` skill finishes writing the context document, it automatically: creates a Worktree from the current repo, opens a new Kitty tab pointed at that Worktree, and starts Claude with the context document as the initial prompt — all without switching focus away from the current session.

A standalone `sidequest` script also becomes available in the terminal for launching sidequests manually, with focus switching to the new tab.

## User Stories

1. As a developer, I want the `/sidequest` skill to automatically open a new Kitty tab with Claude running, so that I don't have to manually set up the environment.
2. As a developer, I want the sidequest Kitty tab to open in the background (no focus switch), so that my current work is not interrupted.
3. As a developer, I want the new Kitty tab to be named after the Sidequest Slug, so that I can identify it at a glance.
4. As a developer, I want a Worktree to be created automatically for each sidequest, so that sidequest work is isolated from other branches.
5. As a developer, I want the Worktree to be created from the repo I am currently working in, so that the sidequest has access to the right codebase.
6. As a developer, I want the Worktree Directory Name to match the Sidequest Slug, so that tab, Worktree, and branch all have consistent names.
7. As a developer, I want Claude to start with the sidequest context document already loaded, so that the fresh agent immediately has all the context it needs.
8. As a developer, I want the `/sidequest` skill to confirm completion with the message "Sidequest created in tab `<slug>`", so that I know the tab was created without having to switch to it.
9. As a developer, I want to run `sidequest <slug>` from my terminal to manually launch a sidequest, so that I can start focused work without going through Claude.
10. As a developer, I want `sidequest <slug>` from the terminal to focus the new Kitty tab immediately, so that I am taken directly to the new work context.
11. As a developer, I want the Sidequest Slug to be at most 2 words in kebab-case, so that tab titles and Worktree Directory Names remain short and readable.
12. As a developer, I want the same `sidequest` script to be used by both the skill and the terminal, so that there is a single source of truth for the launch logic.
13. As a developer, I want `sidequest-end` to call `sidequest` with `--no-focus` instead of writing to the clipboard, so that the launch is fully automated from the skill.
14. As a developer, I want `kitty-helper-claude-start` to accept an optional prompt argument passed to Claude, so that the sidequest context document can be injected at startup.
15. As a developer, I want `kitty-helper-claude-start` to fall back to an interactive zsh shell when Claude exits, so that the Kitty tab remains usable after the session ends.
16. As a developer, I want `kitty-tab-create` to accept an optional `--cmd` flag, so that a custom startup command (like `kitty-helper-claude-start`) can be used instead of plain zsh.

## Implementation Decisions

### Unified Sidequest Slug

A single 2-word-max kebab-case slug is used for the sidequest context document filename, the Worktree branch name, the Worktree Directory Name, and the Kitty tab title. The slug is derived by the `/sidequest` skill from the conversation context. This replaces the previous 3-5 word slug.

### `sidequest` as the single entry point

A new `sidequest <slug> [--prompt <value>] [--no-focus]` bin script is the sole orchestrator of the launch flow:
- Creates the Worktree via `git-worktree-create <slug>` (the cd side-effect is confined to the bin script's subprocess and does not affect the caller's shell)
- Derives the Worktree path from `$OROSHI_WORKTREES_DIR` and the Repo Name
- Creates a Kitty tab titled `<slug>` pointing at the Worktree via `kitty-tab-create` with `--cmd`
- Passes `--prompt` to `kitty-helper-claude-start` if provided
- Applies `--keep-focus` by default; `--no-focus` is the default behavior; focus is only given when called without `--no-focus` (terminal use)

### `sidequest-end` as a thin wrapper

`sidequest-end <filepath>` is simplified to:
- Extract the Sidequest Slug from the filepath basename (strip `.md`)
- Call `sidequest <slug> --prompt @<filepath> --no-focus`
- Remove all clipboard logic

### `kitty-helper-claude-start` replaces `kitty-run-claude`

`kitty-run-claude` is renamed to `kitty-helper-claude-start`. The `kitty-helper-` prefix signals it is an internal helper command meant to be passed as `--cmd` to kitty window/tab creators — not invoked directly by the user. The script is modified to accept an optional positional argument that is passed as the initial prompt to Claude.

### `kitty-tab-create` gains `--cmd` support

`kitty-tab-create` is extended with an optional `--cmd <command>` flag (default: `zsh`), mirroring the existing `--cmd` support already present in `kitty-window-create`. This allows `sidequest` to launch `kitty-helper-claude-start` directly in the new tab.

### `/sidequest` skill updated

The SKILL.md is updated to:
- Derive a slug of at most 2 words (was 3-5)
- Replace the checklist item about `sidequest-end` with a note that the tab, Worktree, and Claude session are created automatically
- Output the confirmation message: "Sidequest created in tab `<slug>`" after running `sidequest-end`

### Focus behavior

- Called from terminal (`sidequest <slug>`): Kitty focuses the new tab
- Called from skill (`sidequest <slug> --no-focus`): Kitty keeps focus on the current tab

### All references to `kitty-run-claude` updated

`kitty-window-toggle-claude` currently passes `--cmd "kitty-run-claude"` — this must be updated to `--cmd "kitty-helper-claude-start"`.

## Testing Decisions

Good tests verify external behavior only: what the script outputs, what files it creates, what commands it calls — not how it does it internally.

### `sidequest-end`

Tests are written for the **current state first** (before any modification), establishing a baseline. Then updated to cover the new behavior. Use `bats_mock` to stub `sidequest` and `clipboard-write`. Tests verify:
- Exits with error when no argument is provided
- Exits with error when file does not exist
- Calls `sidequest` with the correct slug extracted from the filepath
- Passes `--no-focus` and `--prompt @<filepath>` to `sidequest`
- Does NOT call `clipboard-write`

Prior art: `scripts/bin/ai/ralph/__tests__/ralph.bats` — uses `bats_mock` to stub `claude` and `git-commit-message`, then calls `bats_run_script` to run the script under test.

### `sidequest`

Tests use `bats_mock` to stub `git-worktree-create`, `kitty@ launch` (or `kitty-tab-create`), and `kitty-helper-claude-start`. Tests verify:
- Exits with error when no slug is provided
- Creates the Worktree with the correct slug
- Creates a Kitty tab with the correct title and cwd
- Passes `--prompt` to `kitty-helper-claude-start` when provided
- Uses `--keep-focus` by default (terminal mode)
- Uses `--no-focus` when `--no-focus` flag is passed

## Out of Scope

- Automatic cleanup or deletion of sidequest Worktrees — the user manages Worktree lifecycle manually
- Worktree creation outside of `$OROSHI_WORKTREES_DIR` — the existing `git-worktree-create` convention is respected
- Passing a prompt to `sidequest` from the terminal (terminal use always launches Claude without an initial prompt)
- Any changes to the sidequest context document template
- Renaming other `kitty-run-*` scripts beyond `kitty-run-claude`
