## Problem Statement

When `sidequest` opens a new Kitty tab and launches Claude with an initial prompt, closing the Claude session also closes the Kitty window. Users expect the terminal to stay open with a zsh shell after Claude exits, matching the behavior of the no-prompt code path.

## Solution

Update the Claude starter script so that both code paths — with and without an initial prompt — always fall back to a zsh shell after Claude exits, regardless of Claude's exit code.

## User Stories

1. As a developer, I want the Kitty tab to stay open after a prompted Claude session ends, so that I can continue working in the terminal without reopening a new tab.
2. As a developer, I want zsh to appear after Claude exits even if Claude crashes or exits with an error, so that I am not left with a closed window unexpectedly.
3. As a developer, I want the no-prompt and with-prompt code paths to behave identically on exit, so that the experience is predictable regardless of how the tab was opened.

## Implementation Decisions

- Both code paths in the Claude starter script (`with prompt` and `no prompt`) are updated to absorb Claude's exit code using `|| true`, so a non-zero exit does not prevent the fallback.
- Both code paths use plain `zsh` (without `exec`) as the fallback, replacing the previous `exec zsh` in the no-prompt branch and `exit 0` in the with-prompt branch.
- Removing `exec` has no behavioral difference for the user: since `zsh` is the last statement in both branches, the parent process exits when zsh exits regardless.
- No changes are needed to `sidequest` or any other caller — the fix is entirely contained in the Claude starter script.

## Testing Decisions

Good tests verify external behavior only: that the correct commands are called with the correct arguments, and that the script exits cleanly. Tests do not assert on internal implementation details.

**Modules with tests:**
- Claude starter script — both the no-prompt and with-prompt branches

**Test changes:**
- No-prompt test: the manual fake-binary block used to mock `zsh` (create file, chmod, prepend PATH) is replaced with `bats_mock zsh`, which is now possible because `zsh` is called as a function rather than via `exec`.
- With-prompt test: `bats_mock zsh` is added so the script can complete without invoking the real zsh binary.

**Prior art:** existing tests in `kitty-helper-claude-start.bats`, which already mock `git-directory-root` and `claude` using `bats_mock`.

## Out of Scope

- Changing how `sidequest` constructs or passes the prompt argument.
- Handling cases where `git-directory-root` fails (already covered by `set -e`).
- Adding a new fallback mechanism other than zsh.
- Modifying `kitty-window-toggle-claude` or any other caller.

## Further Notes

The worktree is already set up at `oroshi--kitty-fallback` on branch `kitty-fallback`. The fix is small (4 lines changed across 2 files) but corrects an asymmetry that has existed since the with-prompt branch was added.
