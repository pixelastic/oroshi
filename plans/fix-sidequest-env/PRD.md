## Problem Statement

When a sidequest creates a worktree + kitty tab + Claude session, Claude doesn't inherit interactive ZSH environment variables (like `NOTION_TOKEN`). The `kitty-helper-claude-start` script runs `claude` directly in a non-interactive ZSH context (only `.zshenv` sourced), then launches an interactive `zsh` after Claude exits. The env vars from the `.zshrc` chain never reach Claude.

## Solution

Launch Claude inside an interactive ZSH session so it inherits all environment variables from the `.zshrc` chain. When Claude exits, replace the process with a fresh interactive ZSH so the user lands in a working shell.

## User Stories

1. As a developer using sidequests, I want Claude to have access to `NOTION_TOKEN` and other env vars defined in my `.zshrc` chain, so that Claude tools depending on those vars work correctly
2. As a developer, I want to land in an interactive ZSH after Claude exits in a sidequest tab, so that I can continue working
3. As a developer, I want Claude to start in the git root of the worktree, so that file references and commands work relative to the project root
4. As a developer, I want Claude to still work when launched without a prompt argument, so that `kitty-helper-claude-start` remains usable outside of sidequests
5. As a developer, I want the sidequest tab to keep working when Claude exits with a non-zero status, so that a crash doesn't close my tab

## Implementation Decisions

- **`exec zsh -ic "cmd; exec zsh"` pattern**: ZSH has no `--run-then-stay` mode. `zsh -ic` sources `.zshrc` and runs the command, but exits after. The trailing `exec zsh` replaces the process with a fresh interactive shell. This causes double `.zshrc` sourcing (~150ms overhead), which is acceptable.
- **Defensive `cd` in the `-c` command**: The `cd` to the project root is included inside the `-c` string to guard against `.zshrc` potentially changing the working directory during initialization.
- **`${(q)prompt}` quoting**: ZSH's `(q)` parameter expansion flag is used to safely embed the prompt argument (which may contain `@`, spaces, special chars) into the `-c` command string.
- **Delete existing tests**: The previous tests mocked `claude` and `zsh` as executables and verified they were called. With `exec zsh -ic`, the process is replaced entirely and `.zshenv` rebuilds PATH, making mocks unreachable. Mocking `exec` to verify the command string would be a mirror test with no behavioral value. The script is 6 lines — integration testing is the only meaningful validation.

## Testing Decisions

- No automated tests for this change. The behavior (env var inheritance, interactive shell after exit) is only verifiable through integration testing in a real kitty terminal.
- The existing 3 bats tests are deleted because they cannot test the new `exec`-based approach meaningfully.

## Out of Scope

- Modifying `.zshrc` to support a single-zsh approach (env var hook pattern) — adds coupling for marginal gain
- Changes to `kitty-tab-create` or `sidequest-end` — they only pass through the command, no fix needed
- Testing env var inheritance end-to-end in CI — requires a full terminal environment
